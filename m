Date: Thu, 1 Apr 2004 17:36:49 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap
 complexity fix
Message-Id: <20040401173649.22f734cd.akpm@osdl.org>
In-Reply-To: <20040402011627.GK18585@dualathlon.random>
References: <20040402001535.GG18585@dualathlon.random>
	<Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain>
	<20040402011627.GK18585@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> > it isn't doing anything useful for rw_swap_page_sync, just getting you
> > into memory allocation difficulties.  No need for add_to_page_cache or
> > add_to_swap_cache there at all.  As I say, I haven't tested this path,
> 
> I wouldn't need to call add_to_page_cache either, it's just Andrew
> prefers it.

Well all of this is to avoid a fairly arbitrary BUG_ON in the radix-tree
code.  If I hadn't added that, we'd all be happy.

The code is well-tested and has been thrashed to death in the userspace
radix-tree test harness.
(http://www.zip.com.au/~akpm/linux/patches/stuff/rtth.tar.gz).  Let's
remove the BUG_ON.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
