module NaskEpp::Poll

  def poll_req
    response_xml = request_xml(poll_xml("req", nil))
    if response_xml.search("result").first.attribute("code").value == "1301"
       msg_details_element = response_xml.search("resData").children.find {|ch| ch.class == Nokogiri::XML::Element}
       message = { :msg_id => response_xml.search("msgQ").attribute("id").value.to_i,
         :msg => response_xml.search("msg").last.content,
         :msg_count => response_xml.search("msgQ").attribute("count").value.to_i,
       }
       msg_type = msg_details_element.name
       case msg_type
       when 'delData'
         message[:msg_details] = {
           :id => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'id'}.text,
           :executionDate => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'executionDate'}.text
         }
         message[:msg_type] = msg_type
       when 'pollDomainAutoRenewed'
         message[:msg_details] = {
           :name => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'name'}.text,
         }
         message[:msg_type] = msg_type
       when 'pollDomainAutoRenewFailed'
         message[:msg_details] = {
           :name => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'name'}.text,
         }
         message[:msg_type] = msg_type
       when 'trnData'
         message[:msg_details] = {
           :name => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'name'}.text,
           :trStatus => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'trStatus'}.text,
           :reID => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'reID'}.text,
           :reDate => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'reDate'}.text,
           :acID => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'acID'}.text,
           :acDate => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'acDate'}.text,
         }
         ex_date = msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'exDate'}
         message[:msg_details][:exDate] = ex_date.text unless ex_date.nil?
         message[:msg_type] = msg_type
       when 'accountBalanceCrossed'
         message[:msg_details] = {
           :accountType => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'accountType'}.text,
           :notificationLevel => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'notificationLevel'}.text
         }
         message[:msg_type] = msg_type
       when 'passwdReminder'
         message[:msg_details] = {
           :exDate => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'exDate'}.text
         }
         message[:msg_type] = msg_type
       when 'expData'
         message[:msg_details] = {
           :name => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'name'}.text,
           :exDate => msg_details_element.children.find {|ch| ch.class == Nokogiri::XML::Element and ch.name == 'exDate'}.text
         }
         message[:msg_type] = msg_type
       else
         raise 'unknown msg'
       end
      return message
    end
  end

  def poll_ack(msg_id)
    request_element_attribute(poll_xml("ack", msg_id), :result, :code) == "1000"
  end

  private

    def poll_xml(op, msg_id)
"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?> <epp xmlns=\"#{NaskEpp::EPP_SCHEMA}\"
xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"#{NaskEpp::EPP_SCHEMA_LOCATION}\">
    <command>
      <poll op=\"#{op}\"#{" msgID=\"#{msg_id}\" " if op == "ack"}/>
      <clTRID>ABC-12345</clTRID>
    </command>
</epp>"
    end

end
