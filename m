Date: Tue, 25 Jul 2000 14:43:29 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Allocating large chunks of mem from net-bh
Message-ID: <20000725144329.F1396@redhat.com>
References: <00df01bff54f$280d1230$398d96d4@checkpoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00df01bff54f$280d1230$398d96d4@checkpoint.com>; from roman@checkpoint.com on Mon, Jul 24, 2000 at 11:11:26AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Mitnitski <roman@checkpoint.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jul 24, 2000 at 11:11:26AM +0200, Roman Mitnitski wrote:
> 
> I need to allocate (dynamically, as the need arises) large memory areas
> from the bottom-half context (net-bh, to be exact) in Linux 2.2.x. 
> 
> kmalloc does not let me allocate as much memory as I need, and
> vmalloc refuses to work in bottom-half context. 
> 
> I don't need anything special from the allocated memory, (like physical continuity,
> or DMA area). I even don't care much how long
> it takes to allocate, sice it really does not happen that much often.
> 
> Is there any reasonable workaround that would let me solve this problem?

Yep.  Just call get_free_page() to allocate as many individual pages
as you want.  I assume that if you don't need physical contiguity,
then tracking that set of pages will be fine for you.

kiobufs will provide convenient containers for such sets of pages in
2.4 if you want them, and we're adding things like support
functionality for the allocation of arbitrary pages directly into
kiobufs for 2.5.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
