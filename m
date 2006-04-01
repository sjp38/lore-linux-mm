Date: Fri, 31 Mar 2006 16:14:10 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
Message-Id: <20060331161410.733cf360.akpm@osdl.org>
In-Reply-To: <20060331160032.6e437226.akpm@osdl.org>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
	<20060331150120.21fad488.akpm@osdl.org>
	<Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>
	<20060331153235.754deb0c.akpm@osdl.org>
	<Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com>
	<20060331160032.6e437226.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
>  A plain old sysrq-T would be great.
>

Really great.

We do potentially-vast gobs of waiting for I/O in
prune_icache->dispose_list->truncate_inode_pages().

But then, why would dispose_list() run truncate_inode_pages()?  Reclaiming
an inode which has no links to it, perhaps - it's been a while since I was
in there <wishes he added more comments last time he understood that stuff>

clear_inode() does wait_on_inode()...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
