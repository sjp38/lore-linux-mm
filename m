Date: Wed, 15 Nov 2000 10:56:39 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Question about pte_alloc()
Message-ID: <20001115105639.C3186@redhat.com>
References: <3A12363A.3B5395AF@cse.iitkgp.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3A12363A.3B5395AF@cse.iitkgp.ernet.in>; from sganguly@cse.iitkgp.ernet.in on Wed, Nov 15, 2000 at 02:07:38AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
Cc: linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Nov 15, 2000 at 02:07:38AM -0500, Shuvabrata Ganguly wrote:
> 
> it appears from the code that pte_alloc() might block since it allocates
> a page table with GFP_KERNEL if the page table doesnt already exist. i
> need to call pte_alloc() at interrupt time.

You cannot safely play pte games at interrupt time.  You _must_ do
this in the foreground.

 >Basically i want to map some
> kernel memory into user space as soon as the device gives me data.

Why can't you just let the application know that the event has
occurred and then let it mmap the data itself?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
