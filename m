Date: Fri, 23 Feb 2007 11:16:30 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] [PATCH 2.6.20-mm2] Optionally inherit mlockall() semantics
 across fork()/exec()
In-Reply-To: <1172242682.5059.19.camel@localhost>
Message-ID: <Pine.LNX.4.64.0702231111070.31495@schroedinger.engr.sgi.com>
References: <1172178237.5341.38.camel@localhost>
 <Pine.LNX.4.64.0702221507080.22567@schroedinger.engr.sgi.com>
 <1172242682.5059.19.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Feb 2007, Lee Schermerhorn wrote:

> The semantics of mlockall(), whether you use the '_CURRENT and/or the
> '_FUTURE flag, apply to the entire address space of the process.  [See
> http://www.opengroup.org/onlinepubs/7990989775/xsh/mlockall.html]  The
> patch enables inheritance of these semantics across fork() [CURRENT] and
> exec() [FUTURE].

Ahh. I see. Then setting a flags in the vma would work? There is already 
logic to handle VM_LOCKED in mm/mlock.c and we keep on checking 
vma->vm_flags. Maybe add VM_LOCKED_FUTURE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
