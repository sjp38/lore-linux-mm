Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id A73CD6B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 11:44:29 -0400 (EDT)
Received: by lahi5 with SMTP id i5so3458385lah.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 08:44:27 -0700 (PDT)
Date: Sat, 16 Jun 2012 19:44:24 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 3.5] c/r: prctl: less paranoid prctl_set_mm_exe_file()
Message-ID: <20120616154424.GG32029@moon>
References: <20120616085104.14682.16723.stgit@zurg>
 <20120616090646.GD32029@moon>
 <20120616091712.GA2021@moon>
 <4FDC54FF.3020305@openvz.org>
 <20120616094714.GF32029@moon>
 <4FDCA875.6040905@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FDCA875.6040905@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Pavel Emelianov <xemul@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Helsley <matthltc@us.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Sat, Jun 16, 2012 at 07:38:29PM +0400, Konstantin Khlebnikov wrote:
> >Yeah, you've changed !path_equal to path_equal. And yes, getting rid of
> >num_exe_file_vmas is good idea. Btw, Konstantin, why do we need to
> >call for path_equal? Maybe we can simply test for mm->exe_file == NULL,
> >and refuse to change anything if it's not nil value? This will simplify
> >the code.
> 
> After removing VM_EXECUTABLE and mm->num_exe_file_vmas mm->exe_file
> will never becomes NULL automatically. Patch for this not commited yet,
> but I hope it will be in 3.6.

OK, lets stick with current patch then.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
