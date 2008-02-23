Received: by wf-out-1314.google.com with SMTP id 25so853157wfc.11
        for <linux-mm@kvack.org>; Sat, 23 Feb 2008 00:08:13 -0800 (PST)
Message-ID: <e2e108260802230008y4179970dw6581c1a361eac280@mail.gmail.com>
Date: Sat, 23 Feb 2008 09:08:13 +0100
From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: SMP-related kernel memory leak
In-Reply-To: <47BF5932.9040200@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <e2e108260802190300k5b0f60f6tbb4f54997caf4c4e@mail.gmail.com>
	 <e2e108260802210048y653031f3r3104399f126336c5@mail.gmail.com>
	 <e2e108260802210800x5f55fee7ve6e768607d73ceb0@mail.gmail.com>
	 <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com>
	 <6101e8c40802210825v534f0ce3wf80a18ebd6dee925@mail.gmail.com>
	 <47BDEFB4.1010106@zytor.com>
	 <6101e8c40802220844h2553051bw38154dbad91de1e3@mail.gmail.com>
	 <47BEFD5D.402@zytor.com>
	 <6101e8c40802221512t295566bey5a8f1c21b8751480@mail.gmail.com>
	 <47BF5932.9040200@zytor.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Oliver Pinter <oliver.pntr@gmail.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 23, 2008 at 12:22 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> Oliver Pinter wrote:
>  > hi thanks,
>  > but 421d99193537a6522aac2148286f08792167d5fd is never in 2.6.22.y  and
>  > nor stable-queue-2.6.22.y ...
>
>  That's a serious problem.  This is a critical bug.

The patch referenced above modifies a single file:
include/asm-generic/tlb.h. I had a look at the git history of Linus'
2.6.24 tree, and noticed that the cited patch was applied on December
18, 2007 to Linus' tree by Christoph Lameter. Two weeks later, on
December 27, the change was reverted by Christoph. Christoph, can you
provide us some more background information about why the patch was
reverted ?

See also:
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.24.y.git;a=history;f=include/asm-generic/tlb.h;h=75f2bfab614f40639090702a2a6268f34864df75;hb=HEAD

Bart Van Assche.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
