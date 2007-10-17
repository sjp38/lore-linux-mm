Message-ID: <02e801c8108c$4d7ca7a0$3708a8c0@arcapub.arca.com>
From: "Jacky\(GuangXiang  Lee\)" <gxli@arca.com.cn>
References: <20071011075743.GA4654@skynet.ie> <01f601c80be8$39537c70$3708a8c0@arcapub.arca.com> <20071011095622.GB4654@skynet.ie> <040c01c80cab$02e6a4f0$3708a8c0@arcapub.arca.com> <20071012101955.GA27254@skynet.ie> <003601c80ee8$c6487ce0$3708a8c0@arcapub.arca.com> <20071015092426.GA31490@skynet.ie> <016401c80f21$bf0e6c30$3708a8c0@arcapub.arca.com> <20071015130744.GA26741@skynet.ie> <024a01c80fcd$ff785e50$3708a8c0@arcapub.arca.com> <20071016125035.GA4294@skynet.ie>
Subject: Re: where to get ZONE_MOVABLE pathces?
Date: Wed, 17 Oct 2007 15:06:54 +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

----- Original Message ----- 
From: "Mel Gorman" <mel@skynet.ie>
To: "Jacky(GuangXiang Lee)" <gxli@arca.com.cn>
Sent: Tuesday, October 16, 2007 8:50 PM
Subject: Re: where to get ZONE_MOVABLE pathces?



Can I precisely make the RAM range of a specific DIMM to be a independent
zone?
e.x., I have a machine with 2G RAM(in place of 2 DIMM socket , each socket
is plugged with 1G RAM)
then I divided in kernel startup:
 ZONE_DMA: 0~16M
ZONE_DMA32: 16M~1G
ZONE_READONLY:1G~2G (supposing this is my new created zone)
hence the third zone corresponds to a DIMM hardware.
right?


> On (16/10/07 16:24), Jacky(GuangXiang  Lee) didst pronounce:
> > hi Mel,
> > I feel I need more knowledgement about node/zone than reading your that
> > book.
>
> Very well, but it is reaching the point where you should consider
> mailing linux-mm or kernelnewbies so that others will see the answers.
>
> > I have some stupid questions please:
> > 1)In a typical server machine, what are the maximum sizes of each nodes?
Is
> > there some materials about this exists?
>
> The size of the node is only limited by the size of the physical address
> space supported by a machine.
>
> > 2)Are all nodes in the same physical space? e.x., node 1: 0~2G, node 2:
> > 2G~4G,node 3 :4G~6G...?
>
> Not necessarily. Nodes can be at any part of the physical address space.
> They are not necessarily contiguous and nodes can actually overlap in
> some cases. For example, this can happen
>
> Node 0: 0-2GB
> Node 1: 3-6GB
> Node 0: 8-10GB
>
> > 3)In a specific node, does its zones be divided arbitrarily?
> >
>
> No, zones holes pages that have a particular addressing limitation and
> what they mean varies slightly between architectures. On i386, ZONE_DMA
> is 16MB because there are devices that can only use a 24 bit physical
> address. On x86_64, you have ZONE_DMA32 because there are 32 bit devices
> on 64 bit machines.
>
> > Can you give some detailed materials or explain more minutely?
>
> I'm not aware of recent detailed information on the subject. However, if
> you follow the code path starting from
> mm/page_alloc.c#free_area_init_nodes(), you'll see how the zones get
> initialised at boot-time. This is the arch-independent zone-sizing code
> that is used by a number of architectures. You'll see how the arch is
> responsible for passing in an array of PFNs denoting where zones end and
> how this information is used to size zones.
>
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
