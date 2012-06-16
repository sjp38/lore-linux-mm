Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 8E7316B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 05:06:52 -0400 (EDT)
Received: by lahi5 with SMTP id i5so3320029lah.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 02:06:50 -0700 (PDT)
Date: Sat, 16 Jun 2012 13:06:46 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 3.5] c/r: prctl: less paranoid prctl_set_mm_exe_file()
Message-ID: <20120616090646.GD32029@moon>
References: <20120616085104.14682.16723.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120616085104.14682.16723.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Matt Helsley <matthltc@us.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Sat, Jun 16, 2012 at 12:51:04PM +0400, Konstantin Khlebnikov wrote:
> "no other files mapped" requirement from my previous patch
> (c/r: prctl: update prctl_set_mm_exe_file() after mm->num_exe_file_vmas removal)
> is too paranoid, it forbids operation even if there mapped one shared-anon vma.
> 
> Let's check that current mm->exe_file already unmapped, in this case exe_file
> symlink already outdated and its changing is reasonable.
> 
> Plus, this patch fixes exit code in case operation success.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Reported-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Matt Helsley <matthltc@us.ibm.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> ---

Ack! Thanks again, Konstantin!

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
