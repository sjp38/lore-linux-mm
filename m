Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9465B8E00E5
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 19:47:35 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id t133so15768851iof.20
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:47:35 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id x6si8743562jaj.62.2018.12.11.16.47.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Dec 2018 16:47:34 -0800 (PST)
Message-ID: <d447ac4e18bddd030aa2f56a0547c0132b3f8dcd.camel@kernel.crashing.org>
Subject: Re: use generic DMA mapping code in powerpc V4
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 12 Dec 2018 11:47:16 +1100
In-Reply-To: <82879d3f-83de-6438-c1d6-49c571dcb671@xenosoft.de>
References: <20181129170351.GC27951@lst.de>
	 <d0e04a85-f17d-414e-6fea-971414417430@xenosoft.de>
	 <20181130105346.GB26765@lst.de>
	 <8694431d-c669-b7b9-99fa-e99db5d45a7d@xenosoft.de>
	 <20181130131056.GA5211@lst.de>
	 <25999587-2d91-a63c-ed38-c3fb0075d9f1@xenosoft.de>
	 <c5202d29-863d-1377-0e2d-762203b317e2@xenosoft.de>
	 <58c61afb-290f-6196-c72c-ac7b61b84718@xenosoft.de>
	 <20181204142426.GA2743@lst.de>
	 <ef56d279-f75d-008e-71ba-7068c1b37c48@xenosoft.de>
	 <20181205140550.GA27549@lst.de>
	 <1948cf84-49ab-543c-472c-d18e27751903@xenosoft.de>
	 <5a2ea855-b4b0-e48a-5c3e-c859a8451ca2@xenosoft.de>
	 <7B6DDB28-8BF6-4589-84ED-F1D4D13BFED6@xenosoft.de>
	 <8a2c4581-0c85-8065-f37e-984755eb31ab@xenosoft.de>
	 <424bb228-c9e5-6593-1ab7-5950d9b2bd4e@xenosoft.de>
	 <c86d76b4-b199-557e-bc64-4235729c1e72@xenosoft.de>
	 <1ecb7692-f3fb-a246-91f9-2db1b9496305@xenosoft.de>
	 <6c997c03-e072-97a9-8ae0-38a4363df919@xenosoft.de>
	 <4cfb3f26-74e1-db01-b014-759f188bb5a6@xenosoft.de>
	 <82879d3f-83de-6438-c1d6-49c571dcb671@xenosoft.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>, Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On Tue, 2018-12-11 at 19:17 +0100, Christian Zigotzky wrote:
> X5000 (P5020 board): U-Boot loads the kernel and the dtb file. Then the 
> kernel starts but it doesn't find any hard disks (partitions). That 
> means this is also the bad commit for the P5020 board.

What are the disks hanging off ? A PCIe device of some sort ?

Can you send good & bad dmesg logs ?

Ben.
