module AutoSessionTimeoutWarningHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    timeout = options[:timeout] || 60
    start = options[:start] || 60
    warning = options[:warning] || 20
    code = <<JS
if(typeof(jQuery) != 'undefined'){
  $("#logout_dialog").dialog({
    modal: true,
    bgiframe: true,
    width: 500,
    height: 180,
    autoOpen: false,
    dialogClass: "no-close"
  });

  $(".logout_dialog").click(function (e) {
    e.preventDefault();

    $("#logout_dialog").dialog('option', 'buttons', {
      "Continue": function () {
        window.location.reload();
      }
    });

    $("#logout_dialog").dialog("open");

  });

  function PeriodicalQuery() {
    $.ajax({
      url: '/active',
      success: function(data) {
        if(data == 'false'){
          showDialog();
          setTimeout(doTimeout, (#{warning} * 1000));
        }
      }
    });
    setTimeout(PeriodicalQuery, (#{frequency} * 1000));
  }
  setTimeout(PeriodicalQuery, (#{start} * 1000));

  function showDialog(){
    $('.logout_dialog').trigger('click');
  }

  function doTimeout(){
    window.location.href = '/timeout';
  }
}
JS
    javascript_tag(code)
  end

  def auto_session_warning_tag(options={})
    "<div id='logout_dialog' title='Logout Message' style='display:none;'>
      You are about to be logged out of this system.
      <br/><br/>
      Please click Continue if you want to stay logged in.
      </div> <div class='logout_dialog'></div>".html_safe
  end
end

ActionView::Base.send :include, AutoSessionTimeoutWarningHelper