Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 961256B6F20
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 09:24:28 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id j30so13265598wre.16
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 06:24:28 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u18si13389838wrd.292.2018.12.04.06.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 06:24:27 -0800 (PST)
Date: Tue, 4 Dec 2018 15:24:26 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181204142426.GA2743@lst.de>
References: <87zhttfonk.fsf@concordia.ellerman.id.au> <4d4e3cdd-d1a9-affe-0f63-45b8c342bbd6@xenosoft.de> <20181129170351.GC27951@lst.de> <d0e04a85-f17d-414e-6fea-971414417430@xenosoft.de> <20181130105346.GB26765@lst.de> <8694431d-c669-b7b9-99fa-e99db5d45a7d@xenosoft.de> <20181130131056.GA5211@lst.de> <25999587-2d91-a63c-ed38-c3fb0075d9f1@xenosoft.de> <c5202d29-863d-1377-0e2d-762203b317e2@xenosoft.de> <58c61afb-290f-6196-c72c-ac7b61b84718@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58c61afb-290f-6196-c72c-ac7b61b84718@xenosoft.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On Tue, Dec 04, 2018 at 10:53:39AM +0100, Christian Zigotzky wrote:
> I don't know why this kernel doesn't recognize the hard disks connected to 
> my physical P5020 board and why the onboard ethernet on my PASEMI board 
> doesn't work. (dma_direct_map_page: overflow)

Do you know if this actually works for the baseline before my patches?
E.g. with commit 721c01ba8b46ddb5355bd6e6b3bbfdabfdf01e97 ?
