Subject: Re: uncached page allocator
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <21d7e9970708202305h5128aa5cy847dafe033b00742@mail.gmail.com>
References: <21d7e9970708191745h3b579f3bp72f138e089c624da@mail.gmail.com>
	 <20070820094125.209e0811@the-village.bc.nu>
	 <21d7e9970708202305h5128aa5cy847dafe033b00742@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 21 Aug 2007 16:56:05 +0200
Message-Id: <1187708165.6114.256.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, dri-devel <dri-devel@lists.sourceforge.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-21 at 16:05 +1000, Dave Airlie wrote:

> So you can see why some sort of uncached+writecombined page cache
> would be useful, I could just allocate a bunch of pages at startup as
> uncached+writecombined, and allocate pixmaps from them and when I
> bind/free the pixmap I don't need the flush at all, now I'd really
> like this to be part of the VM so that under memory pressure it can
> just take the pages I've got in my cache back and after flushing turn
> them back into cached pages, the other option is for the DRM to do
> this on its own and penalise the whole system.

Can't you make these pages part of the regular VM by sticking them all
into an address_space.

And for this reclaim behaviour you'd only need to set PG_private and
have a_ops->releasepage() dtrt.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
