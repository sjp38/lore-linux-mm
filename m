Date: Fri, 30 Jul 2004 16:34:43 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
Message-Id: <20040730163443.37f9b309.pj@sgi.com>
In-Reply-To: <Pine.SGI.4.58.0407301633051.36748@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407292006290.1096-100000@localhost.localdomain>
	<Pine.SGI.4.58.0407301633051.36748@kzerza.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: hugh@veritas.com, wli@holomorphy.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Brent wrote:
> Having a single CPU fault in all the pages will generally
> cause all pages to reside on a single NUMA node.

Couldn't one use Andi Kleen's numa mbind() to layout the
memory across the desired nodes, before faulting it in?

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
