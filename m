Date: Wed, 27 Apr 2005 16:33:51 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFC 3/4] VM: toss_page_cache_node syscall
Message-Id: <20050427163351.442aca08.akpm@osdl.org>
In-Reply-To: <20050427150952.GU8018@localhost>
References: <20050427145734.GL8018@localhost>
	<20050427150952.GU8018@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Martin Hicks <mort@sgi.com> wrote:
>
> This just adds a simple syscall to call into the reclaim code.
> The use for this would be to clear all unneeded pagecache and slabcache
> off a node before running a big HPC job.
> 
> A "memory freer" app can be found at:
> http://www.bork.org/~mort/sgi/localreclaim/reclaim_memory.c

I renamed "toss" to "reclaim".  We don't want to confirm that mm developers
are a bunch of tossers.  Please update userspace to suit?

ia64 unistd.h needs patching?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
