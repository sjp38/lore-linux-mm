Date: Wed, 11 Jun 2003 09:22:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: How to fix the total size of buffer caches in 2.4.5?
Message-ID: <20030611162224.GR15692@holomorphy.com>
References: <Pine.LNX.4.44.0306111208200.1570-100000@ickis.cs.wm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0306111208200.1570-100000@ickis.cs.wm.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shansi Ren <sren@CS.WM.EDU>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 11, 2003 at 12:13:34PM -0400, Shansi Ren wrote:
>    I'm trying to implement the pure LRU algorithm and a new page 
> replacement algorithm on top of 2.4.5 kernel, and compare their 
> performance. Can anybody tell me if there is an easy way to seperate the 
> buffer cache management from the virtual memory management? And how to 
> preallocate a chunk of memory for buffer cache usage exclusively, say, 
> 32M exclusively for buffer cache?  Thanks.

What kernel version did you really mean? 2.4.5 sounds implausible to be
what you're really working against.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
