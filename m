Message-ID: <3B030F06.8BE98FC7@mandrakesoft.com>
Date: Wed, 16 May 2001 19:36:38 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: inode/dentry pressure
References: <Pine.LNX.4.33.0105161953170.5251-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org, Alexander Viro <viro@math.psu.edu>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> since the inode and dentry cache memory usage and the way this
> memory is reaped by kswapd are still very fragile and these
> caches often eat as much as 50% of system memory on normal
> desktop systems I think we need to come up with a real solution
> to this problem.
> 
> A quick fix would be to always try and reap inode and dentry
> cache memory whenever these two eat over 10% of memory and let
> the normal VM path eat from them when they're consuming less,
> but since this could break in other situations I'm asking here
> if anybody else has a real solution...
> 
> If we cannot find an easy to implement Real Solution(tm) we
> should probably go for the 10% limit in 2.4 and implement the
> real solution in 2.5; if anybody has a 2.4-attainable idea
> I'd like to hear about it ;)

IMHO this is more of a policy question, though I agree strongly it needs
some sort of answer.

When applications start competing with disposable OS caches, of all
sorts, you have to decide cache reap rate, and a suitable low water mark
for each cache in order for the system to be useable under heavy load. 
Some caches are going to have a higher low-water mark than others; some
caches may need to be reaped more slowly due to various issues.

-- 
Jeff Garzik      | Game called on account of naked chick
Building 1024    |
MandrakeSoft     |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
