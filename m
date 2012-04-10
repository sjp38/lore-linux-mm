Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id C89886B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 19:00:02 -0400 (EDT)
Received: by lagz14 with SMTP id z14so339520lag.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2012 16:00:00 -0700 (PDT)
Date: Wed, 11 Apr 2012 02:59:57 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH mm RESEND] c/r: prctl: update prctl_set_mm_exe_file()
 after mm->num_exe_file_vmas removal
Message-ID: <20120410225957.GP24857@moon>
References: <20120407190801.10294.76053.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120407190801.10294.76053.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Pavel Emelyanov <xemul@parallels.com>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Matt Helsley <matthltc@us.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Sat, Apr 07, 2012 at 11:08:02PM +0400, Konstantin Khlebnikov wrote:
> [ fix for "c-r-prctl-add-ability-to-set-new-mm_struct-exe_file-v2" from mm tree ]
> 
> After removing mm->num_exe_file_vmas kernel keeps mm->exe_file until final mmput(),
> it never becomes NULL while task is alive.
> 
> We can check for other mapped files in mm instead of checking mm->num_exe_file_vmas,
> and mark mm with flag MMF_EXE_FILE_CHANGED in order to forbid second changing of mm->exe_file.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Hi Konstantin, really sorry for delay. This should do trick for us.

Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
