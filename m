Date: Thu, 15 Feb 2007 09:58:48 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] build error: allnoconfig fails on mincore/swapper_space
In-Reply-To: <20070215085500.30e57866.randy.dunlap@oracle.com>
Message-ID: <Pine.LNX.4.64.0702150957110.20368@woody.linux-foundation.org>
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com>
 <20070212150802.f240e94f.akpm@linux-foundation.org> <45D12715.4070408@yahoo.com.au>
 <20070213121217.0f4e9f3a.randy.dunlap@oracle.com>
 <Pine.LNX.4.64.0702132224280.3729@blonde.wat.veritas.com>
 <20070213144909.70943de2.randy.dunlap@oracle.com>
 <Pine.LNX.4.64.0702140009320.21315@blonde.wat.veritas.com>
 <20070215085500.30e57866.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, tony.luck@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 15 Feb 2007, Randy Dunlap wrote:
> 
> so, are we going to get a revert of 42da9cbd3eedde33a42acc2cb06f454814cf5de0 ?
> Has that been requested?  or are there other plans?

It should be fixed now (I had patches from Nick, but got sidetracked by 
trying to fix metacity for the gnome people). 

I've pushed out, but mirroring delays mean that unless you use 
master.kernel.org you'll need to wait a bit. I think Nick cc'd the kernel 
mailing list, though, so you can look for subjects containing "mincore" if 
you need it fixed before that.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
