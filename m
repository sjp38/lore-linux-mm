Date: Wed, 02 Jul 2003 10:10:09 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <461030000.1057165809@flay>
In-Reply-To: <20030702171159.GG23578@dualathlon.random>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <20030701022516.GL3040@dualathlon.random> <Pine.LNX.4.53.0307021641560.11264@skynet> <20030702171159.GG23578@dualathlon.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> the major reason you didn't mention for remap_file_pages is the rmap
> avoidance. There's no rmap backing the remap_file_pages regions, so the
> overhead per task is reduced greatly and the box stops running oom
> (actually deadlocking for mainline thanks to the oom killer and NOFAIL
> default behaviour). 

Maybe I'm just taking this out of context, and it's twisting my brain,
but as far as I know, the nonlinear vma's *are* backed by pte_chains.
That was the whole problem with objrmap having to do conversions, etc.

Am I just confused for some reason? I was pretty sure that was right ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
