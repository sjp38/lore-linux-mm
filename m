Date: Mon, 17 Nov 2003 14:42:58 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH][2.6-mm] Fix 4G/4G X11/vm86 oops
In-Reply-To: <Pine.LNX.4.53.0311171639260.30079@montezuma.fsmlabs.com>
Message-ID: <Pine.LNX.4.44.0311171441380.8840-100000@home.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 2003, Zwane Mwaikambo wrote:
> 
> I've managed to `fix` the triple fault (see further below for the patch 
> in all it's glory).

What's the generated assembly language for this function with and without 
the "fix"?

If adding that printk fixes a triple fault, the issue is not likely to be 
the printk itself as much as the difference in code that the compiler 
generates - stack frame, memory re-ordering etc...

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
