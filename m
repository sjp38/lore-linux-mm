Date: Fri, 6 Jul 2001 18:56:23 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Use of mmap_sem in map_user_kiobuf
Message-ID: <20010706185623.C2425@athlon.random>
References: <3B4597FE.7070901@humboldt.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B4597FE.7070901@humboldt.co.uk>; from adrian@humboldt.co.uk on Fri, Jul 06, 2001 at 11:50:38AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Cox <adrian@humboldt.co.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 06, 2001 at 11:50:38AM +0100, Adrian Cox wrote:
> Does map_user_kiobuf really need to get a write lock on the mmap_sem? 
>  From examination of the code, all it can do is expand_stack(), fault in 
> pages, and increment the count on a page.
> 
> Is there anything I've missed? Would it be safe to use down_read(), 
> up_read() instead?

yes, it should be ok.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
