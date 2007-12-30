Date: Sun, 30 Dec 2007 15:18:29 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 05/10] x86_64: Use generic percpu
Message-ID: <20071230141829.GA28415@elte.hu>
References: <20071228001046.854702000@sgi.com> <20071228001047.556634000@sgi.com> <200712281354.52453.ak@suse.de> <47757311.5050503@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47757311.5050503@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> > Also for such changes .text size comparisons before/after are a good 
> > idea.
> 
> x86_64-defconfig:
> 
> pre-percpu                          post-percpu
>       159373 .init.text                       +3 .init.text
>      1411137 .rodata                          +8 .rodata
>      3629056 .text                           +48 .text
>      7057383 Total                           +59 Total

ok, that looks like really minimal impact, so i'm in favor of merging 
this into arch/x86 - and the unification it does later on is nice too.

to get more test feedback: what would be the best way to get this tested 
in x86.git in a standalone way? Can i just pick up these 10 patches and 
remove all the non-x86 arch changes, and expect it to work - or are the 
other percpu preparatory/cleanup patches in -mm needed too?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
