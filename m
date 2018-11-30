Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2B236B58E6
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 10:30:02 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id y1so4169610wrd.7
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 07:30:02 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::11])
        by mx.google.com with ESMTPS id q9si4037072wrw.84.2018.11.30.07.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 07:30:01 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
References: <20181114082314.8965-1-hch@lst.de> <20181127074253.GB30186@lst.de>
 <87zhttfonk.fsf@concordia.ellerman.id.au>
 <4d4e3cdd-d1a9-affe-0f63-45b8c342bbd6@xenosoft.de>
 <20181129170351.GC27951@lst.de>
 <d0e04a85-f17d-414e-6fea-971414417430@xenosoft.de>
 <20181130105346.GB26765@lst.de>
 <8694431d-c669-b7b9-99fa-e99db5d45a7d@xenosoft.de>
 <20181130131056.GA5211@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <25999587-2d91-a63c-ed38-c3fb0075d9f1@xenosoft.de>
Date: Fri, 30 Nov 2018 16:29:40 +0100
MIME-Version: 1.0
In-Reply-To: <20181130131056.GA5211@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Olof Johansson <olof@lixom.net>, Darren Stevens <darren@stevens-zone.net>, Julian Margetson <runaway@candw.ms>

Hello Christoph,

Thanks for your reply.

On 30 November 2018 at 2:10PM, Christoph Hellwig wrote:
> On Fri, Nov 30, 2018 at 01:23:20PM +0100, Christian Zigotzky wrote:
>> Yes, of course. I patched your Git kernel and after that I compiled it
>> again. U-Boot loads the kernel and the dtb file. Then the kernel starts but
>> it doesn't find any hard disks (partitions).
> Interesting.  Does it find the storage controller (what kind of
> storage does it use?).
It seems not. I don't see any infos about hard disks in the kernel ring 
buffer. The two serial ATA (SATA 2.0) controllers are integrated in the 
P5020 SoC and the hard disks are connected via SerDes lanes (PCIe) to 
the SoC. LANE 16 = SATA 0 and LANE 17 = SATA 1.
> For the PASEMI board can you test the attached patch?  Also are you
> using Compact Flash cards on that system?
Yes, we are using Compact Flash cards. The slot is wired to the CPU 
local bus. It works with your kernel. :-)

Where is the attached patch?

I downloaded the version 5 of your Git kernel and compiled it today. 
Unfortunately the PASEMI ethernet doesn't work.

Error message: pci 0000:00:1a.0: dma_direct_map_page: overflow 
0x000000026bcb5002+110 of device mask ffffffff bus mask 0

@All
Could you please also test Christoph's kernel on your PASEMI and NXP boards? Download:

'git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.5 a'

Thanks,
Christian
