Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF266B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 21:34:56 -0400 (EDT)
Received: by pvc12 with SMTP id 12so1288358pvc.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 18:34:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305767957.2375.117.camel@sli10-conroe>
References: <BANLkTimo=yXTrgjQHn9746oNdj97Fb-Y9Q@mail.gmail.com>
	<1305767957.2375.117.camel@sli10-conroe>
Date: Thu, 19 May 2011 03:34:55 +0200
Message-ID: <BANLkTik2UvgpsW-y_gZki_06KGGss+XABA@mail.gmail.com>
Subject: Re: driver mmap implementation for memory allocated with pci_alloc_consistent()?
From: Leon Woestenberg <leon.woestenberg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, linux-mm@kvack.org

Hello,

On Thu, May 19, 2011 at 3:19 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Wed, 2011-05-18 at 21:02 +0800, Leon Woestenberg wrote:
> why use pci_alloc_consistent? you can allocate pages and mmap it to
> userspace. when you want to do dma, you can use pci_map_page to get dma
> address for the pages and do whatever.
>
Thanks for thinking along.

I need contiguous memory in this case.  But yes, I have just found out
that __get_free_pages() with pci_map_single()  does work with my
mmap() fault() handler.
See my other thread with the code posted.

I just want to understand how this would work with
pci_alloc_consistent(), as that is the generic interface for PCI
drivers.

Note that the latter provides consistent / coherent mapping, whereas
pci_map_single() does not in general.   On x86 it probably is the same
due to bus-snooping (right?).

Regards,
--
Leon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
