Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id DDA346B6E1D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:53:46 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id f193so5432535wme.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:53:46 -0800 (PST)
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::8])
        by mx.google.com with ESMTPS id v14si12470303wrr.363.2018.12.04.01.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 01:53:45 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <20181114082314.8965-1-hch@lst.de> <20181127074253.GB30186@lst.de>
 <87zhttfonk.fsf@concordia.ellerman.id.au>
 <4d4e3cdd-d1a9-affe-0f63-45b8c342bbd6@xenosoft.de>
 <20181129170351.GC27951@lst.de>
 <d0e04a85-f17d-414e-6fea-971414417430@xenosoft.de>
 <20181130105346.GB26765@lst.de>
 <8694431d-c669-b7b9-99fa-e99db5d45a7d@xenosoft.de>
 <20181130131056.GA5211@lst.de>
 <25999587-2d91-a63c-ed38-c3fb0075d9f1@xenosoft.de>
 <c5202d29-863d-1377-0e2d-762203b317e2@xenosoft.de>
Message-ID: <58c61afb-290f-6196-c72c-ac7b61b84718@xenosoft.de>
Date: Tue, 4 Dec 2018 10:53:39 +0100
MIME-Version: 1.0
In-Reply-To: <c5202d29-863d-1377-0e2d-762203b317e2@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On 04 December 2018 at 08:31AM, Christian Zigotzky wrote:
> Hi All,
>
> Could you please test Christoph's kernel on your PASEMI and NXP 
> boards? Download:
>
> 'git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.5 a'
>
> Thanks,
> Christian
>
I successfully tested this kernel on a virtual e5500 QEMU machine today.

Command: ./qemu-system-ppc64 -M ppce500 -cpu e5500 -m 2048 -kernel 
uImage-dma -drive 
format=raw,file=MATE_PowerPC_Remix_2017_0.9.img,index=0,if=virtio -nic 
user,model=e1000 -append "rw root=/dev/vda" -device virtio-vga -device 
virtio-mouse-pci -device virtio-keyboard-pci -usb -soundhw es1370 -smp 4

QEMU version 3.1.0.

I don't know why this kernel doesn't recognize the hard disks connected 
to my physical P5020 board and why the onboard ethernet on my PASEMI 
board doesn't work. (dma_direct_map_page: overflow)

-- Christian
