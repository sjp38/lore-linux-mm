Date: Wed, 16 May 2001 19:34:22 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: inode/dentry pressure
In-Reply-To: <Pine.LNX.4.33.0105161953170.5251-100000@duckman.distro.conectiva>
Message-ID: <Pine.GSO.4.21.0105161932260.26191-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>


On Wed, 16 May 2001, Rik van Riel wrote:

> If we cannot find an easy to implement Real Solution(tm) we
> should probably go for the 10% limit in 2.4 and implement the
> real solution in 2.5; if anybody has a 2.4-attainable idea
> I'd like to hear about it ;)

Rip the crap from icache hard, fast and often. _Any_ inode with
no dentry is fair game as soon as it's clean. Keep in mind
that icache is a secondary cache - we are talking about the
stuff dcache didn't want to keep.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
