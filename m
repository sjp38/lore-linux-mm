Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BAF2A6B6D85
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:31:14 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id y7so12771813wrr.12
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:31:14 -0800 (PST)
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::5])
        by mx.google.com with ESMTPS id h10si12729281wre.279.2018.12.03.23.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:31:12 -0800 (PST)
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
Message-ID: <c5202d29-863d-1377-0e2d-762203b317e2@xenosoft.de>
Date: Tue, 4 Dec 2018 08:31:03 +0100
MIME-Version: 1.0
In-Reply-To: <25999587-2d91-a63c-ed38-c3fb0075d9f1@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Hi All,

Could you please test Christoph's kernel on your PASEMI and NXP boards? 
Download:

'git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.5 a'

Thanks,
Christian
