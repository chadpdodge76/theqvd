<table>
    <tr data-tab-field="general">
        <td data-i18n="Name" class="mandatory-label"></td>
        <td>
            <input id="name" type="text" name="name" value="" data-required>
        </td>
    </tr>
    <tr data-tab-field="general">
        <td data-i18n="Description"></td>
        <td>
            <textarea id="description" type="text" name="description"></textarea>
        </td>
    </tr>
    <tr data-tab-field="software">
        <td data-i18n="OS distro">OS distro</td>
        <td>
            <select class="" id="os_distro_select" name="os_distro_select">
                <option value="<%= OSF_DISTRO_COMMON_ID %>" data-i18n="Custom">Custom</option>
            </select>
        </td>
    </tr>
    <tr data-tab-field="software">
        <td colspan=2 class="bb-os-configuration-editor os-configuration-editor"></td>
    </tr>
    <% 
    if (Wat.C.checkACL('osf.create.memory')) { 
    %>
    <tr data-tab-field="hardware">
        <td data-i18n="Memory"></td>
        <td>
            <input type="text" class="half100" name="memory" value=""> MB
            <div class="second_row" data-i18n>
                <%=
                    '(' + i18n.t('Leave it blank to use the default value: __default_megabytes__ MB', {'default_megabytes': '256'}) + ')'
                %>
            </div>
        </td>
    </tr>
    <% 
    }
    if (Wat.C.checkACL('osf.create.user-storage')) { 
    %>
    <tr data-tab-field="hardware">
        <td data-i18n="User storage"></td>
        <td>
            <input type="text" class="half100" name="user_storage" value="0" data-required> MB
            <div class="second_row">
                (<span data-i18n="Set to 0 for not using User storage"></span>)
            </div>
        </td>
    </tr>
    <% } %>
 </table>