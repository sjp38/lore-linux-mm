Date: Wed, 11 Jun 2003 12:28:18 -0400 (EDT)
From: Shansi Ren <sren@CS.WM.EDU>
Subject: Re: How to fix the total size of buffer caches in 2.4.5?
In-Reply-To: <20030611162224.GR15692@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0306111226160.1656-100000@ickis.cs.wm.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

What version do you suggest then? The reason why I choose 2.4.5 is that 
I'm doing a research project. Experiments on earlier versions may not be 
persuasive to audience.


On Wed, 11 Jun 2003, William Lee Irwin III wrote:

> On Wed, Jun 11, 2003 at 12:13:34PM -0400, Shansi Ren wrote:
> >    I'm trying to implement the pure LRU algorithm and a new page 
> > replacement algorithm on top of 2.4.5 kernel, and compare their 
> > performance. Can anybody tell me if there is an easy way to seperate the 
> > buffer cache management from the virtual memory management? And how to 
> > preallocate a chunk of memory for buffer cache usage exclusively, say, 
> > 32M exclusively for buffer cache?  Thanks.
> 
> What kernel version did you really mean? 2.4.5 sounds implausible to be
> what you're really working against.
> 
> 
> -- wli
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
