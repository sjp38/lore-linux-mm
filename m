Date: Fri, 17 May 2002 20:46:36 +0530 (IST)
From: Sanket Rathi <sanket.rathi@cdac.ernet.in>
Subject: Re: Bounce Buffer Patch
In-Reply-To: <20020517060955.GS11948@suse.de>
Message-ID: <Pine.GSO.4.10.10205172040010.27910-100000@mailhub.cdac.ernet.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks
i want to know how kernel does the job for bounce buffer.
i mean how kernel perform tasks of copying data and allocating bounce
buffer.
because if i give an address to a device for DMA then device will start
DMA from there so when kernel comes in picture i am confussed let me know
about this.

Thanks in advance


--- Sanket Rathi

--------------------------

On Fri, 17 May 2002, Jens Axboe wrote:

> On Fri, May 17 2002, Sanket Rathi wrote:
> > I have read about bounce buffer and understand.
> > but from where i can get the code of that patch and how it internally
> > works.
> 
> You mean the patch to avoid bounce buffering? Andrea has an uptodate
> version here:
> 
> http://www.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.4/2.4.19pre8aa3/00_block-highmem-all-18b-11.gz
> 
> In short, it does its magic by not relying on the virtual mapping of a
> given page. If you want more info than that, you'll have to ask more
> qualified questions.
> 
> -- 
> Jens Axboe
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
