Received: by rn-out-0910.google.com with SMTP id i24so1788528rng.0
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 11:15:52 -0700 (PDT)
Message-ID: <4cefeab80803241115l34b37b33ie9eec5404ff8a764@mail.gmail.com>
Date: Mon, 24 Mar 2008 23:45:51 +0530
From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Re: [PATCH 0/6]: compcache: Compressed Caching
In-Reply-To: <5699f8f00803240921j5dc66547xf9a755ee531d8476@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200803242030.05997.nitingupta910@gmail.com>
	 <5699f8f00803240921j5dc66547xf9a755ee531d8476@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wander Winkelhorst <w.winkelhorst@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 9:51 PM, Wander Winkelhorst
<w.winkelhorst@gmail.com> wrote:
>
> On Mon, Mar 24, 2008 at 4:00 PM, Nitin Gupta <nitingupta910@gmail.com>
> wrote:
> > Hi All,
> >
>
> Hi,
>
>
> > (sending to lkml since I didn't get any reply at linux-mm).
> >
> > This implements a RAM based block device which acts as swap disk.
> > Pages swapped to this disk are compressed and stored in memory itself.
> > This allows more applications to fit in given amount of memory. This is
> > especially useful for embedded devices, OLPC and small desktops
> > (aka virtual machines).
> >
>
> I think this is a very interesting patch, but I find the name confusing, it
> isn't actually a compresed cache, now is it? It's just a compressed ramdisk.

In future, I intend to extend it to include page-cache compression also.

> Is it possible to use it as a initramfs as well?
I guess not since R/W have to be page-aligned in this case.

>  How many can I run at the same time?
>

Only 1 for now :)


>
> >
> > Project home: http://code.google.com/p/compcache/
> >
>
> This page shows the usage as:
>
> Loading: run 'use_compcache.sh <size of swap device (KB)>' to load all
> required modules and setup swap device. If size is not specified, default
> size of 25% of RAM is used.
>
> Does that mean that if I load compcache without using it, I still lose 25%
> of my memory? Or is the memory dynamically allocated?
>

Memory is dynamically allocated.


Thanks,
Nitin


> Regards,
> Wander Winkelhorst
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
