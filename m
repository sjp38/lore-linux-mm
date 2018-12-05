Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB716B73AA
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:44:13 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id a11so6731021wmh.2
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:44:13 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::9])
        by mx.google.com with ESMTPS id q7si14846348wru.95.2018.12.05.01.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 01:44:11 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
References: <87zhttfonk.fsf@concordia.ellerman.id.au>
 <4d4e3cdd-d1a9-affe-0f63-45b8c342bbd6@xenosoft.de>
 <20181129170351.GC27951@lst.de>
 <d0e04a85-f17d-414e-6fea-971414417430@xenosoft.de>
 <20181130105346.GB26765@lst.de>
 <8694431d-c669-b7b9-99fa-e99db5d45a7d@xenosoft.de>
 <20181130131056.GA5211@lst.de>
 <25999587-2d91-a63c-ed38-c3fb0075d9f1@xenosoft.de>
 <c5202d29-863d-1377-0e2d-762203b317e2@xenosoft.de>
 <58c61afb-290f-6196-c72c-ac7b61b84718@xenosoft.de>
 <20181204142426.GA2743@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <ef56d279-f75d-008e-71ba-7068c1b37c48@xenosoft.de>
Date: Wed, 5 Dec 2018 10:44:05 +0100
MIME-Version: 1.0
In-Reply-To: <20181204142426.GA2743@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On 04 December 2018 at 3:24PM, Christoph Hellwig wrote:
> On Tue, Dec 04, 2018 at 10:53:39AM +0100, Christian Zigotzky wrote:
>> I don't know why this kernel doesn't recognize the hard disks connected to
>> my physical P5020 board and why the onboard ethernet on my PASEMI board
>> doesn't work. (dma_direct_map_page: overflow)
> Do you know if this actually works for the baseline before my patches?
> E.g. with commit 721c01ba8b46ddb5355bd6e6b3bbfdabfdf01e97 ?
>
Hi Christoph,

Thanks for your reply. I undid all dma mapping commits with the 
following command:

git checkout 721c01ba8b46ddb5355bd6e6b3bbfdabfdf01e97

After that I compiled the kernels with this code for my P5020 board 
(Cyrus) and for my PASEMI board (Nemo) today.

Result: PASEMI onboard ethernet works again and the P5020 board boots.

It seems the dma mapping commits are the problem.

@All
Could you please test Christoph's kernel on your PASEMI and NXP boards? 
Download:

'git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.5 a'

Thanks,
Christian
