Date: Wed, 19 Nov 2003 23:53:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH][2.6-mm] Fix 4G/4G X11/vm86 oops
Message-Id: <20031119235359.37133797.akpm@osdl.org>
In-Reply-To: <20031120074405.GG22139@waste.org>
References: <Pine.LNX.4.53.0311181113150.11537@montezuma.fsmlabs.com>
	<Pine.LNX.4.44.0311180830050.18739-100000@home.osdl.org>
	<20031119203210.GC22139@waste.org>
	<20031119230928.GE22139@waste.org>
	<20031120074405.GG22139@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: torvalds@osdl.org, zwane@arm.linux.org.uk, mingo@elte.hu, mbligh@aracnet.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Matt Mackall <mpm@selenic.com> wrote:
>
>  -	load_esp0(tss, &tsk->thread);
>  +	load_virtual_esp0(tss, tsk);

Thanks guys.

Now I'll have to put something else in there to keep you amused ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
