Date: Wed, 3 Nov 2004 04:05:58 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
Message-ID: <20041103030558.GK3571@dualathlon.random>
References: <4187FA6D.3070604@us.ibm.com> <20041102220720.GV3571@dualathlon.random> <41880E0A.3000805@us.ibm.com> <4188118A.5050300@us.ibm.com> <20041103013511.GC3571@dualathlon.random> <418837D1.402@us.ibm.com> <20041103022606.GI3571@dualathlon.random> <418846E9.1060906@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <418846E9.1060906@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 02, 2004 at 06:48:09PM -0800, Dave Hansen wrote:
> It should be enough, but I don't think we want to waste a bitflag for 
> something that's only needed for debugging anyway.  They're getting 
> precious these days.  Might as well just bloat the kernel some more when 
> the alloc debugging is on.

You can leave the bitflag the end (number 31) under the #ifdef. Using
the bitflag is less likely to create an heisenbug (due different layout
of the ram ;).

> I'll see what I can do to get some backtraces of the __pg_prot(0) &&
> page->mapped cases.

thanks!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
