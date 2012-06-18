Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id DE1BA6B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 04:58:27 -0400 (EDT)
Received: by lahi5 with SMTP id i5so4309459lah.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 01:58:25 -0700 (PDT)
Date: Mon, 18 Jun 2012 12:58:22 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: Re: [PATCH 3.5] c/r: prctl: less paranoid prctl_set_mm_exe_file()
Message-ID: <20120618085822.GA8304@moon>
References: <20120616085104.14682.16723.stgit@zurg>
 <20120616090646.GD32029@moon>
 <20120616091712.GA2021@moon>
 <4FDC54FF.3020305@openvz.org>
 <20120616094714.GF32029@moon>
 <4FDCA875.6040905@openvz.org>
 <20120616154424.GG32029@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120616154424.GG32029@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Pavel Emelianov <xemul@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Helsley <matthltc@us.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Sat, Jun 16, 2012 at 07:44:24PM +0400, Cyrill Gorcunov wrote:
> On Sat, Jun 16, 2012 at 07:38:29PM +0400, Konstantin Khlebnikov wrote:
> > >Yeah, you've changed !path_equal to path_equal. And yes, getting rid of
> > >num_exe_file_vmas is good idea. Btw, Konstantin, why do we need to
> > >call for path_equal? Maybe we can simply test for mm->exe_file == NULL,
> > >and refuse to change anything if it's not nil value? This will simplify
> > >the code.
> > 
> > After removing VM_EXECUTABLE and mm->num_exe_file_vmas mm->exe_file
> > will never becomes NULL automatically. Patch for this not commited yet,
> > but I hope it will be in 3.6.
> 
> OK, lets stick with current patch then.

To clarify

Tested-by: Cyrill Gorcunov <gorcunov@openvz.org>

Andrew, could you please pick up this bugfix. It's critical for us.

P.S. Together with patch https://lkml.org/lkml/2012/6/15/220 it'll be
last changes to prctl in a sake of c/r I think. Would be cool to have
both bugfixes in 3.5.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
