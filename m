Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64C9C8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:35:06 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id a11so534931wmh.2
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:35:06 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::10])
        by mx.google.com with ESMTPS id f17si72995082wru.378.2019.01.23.06.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 06:35:04 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
References: <871403f2-fa7d-de15-89eb-070432e15c69@xenosoft.de>
 <20190118112842.GA9115@lst.de>
 <a2ca0118-5915-8b1c-7cfa-71cb4b43eaa6@xenosoft.de>
 <20190118121810.GA13327@lst.de>
 <eceebeda-0e18-00f6-06e7-def2eb0aa961@xenosoft.de>
 <20190118125500.GA15657@lst.de>
 <e11e61b1-6468-122e-fc2b-3b3f857186bb@xenosoft.de>
 <f39d4fc6-7e4e-9132-c03f-59f1b52260e0@xenosoft.de>
 <b9e5e081-a3cc-2625-4e08-2d55c2ba224b@xenosoft.de>
 <20190119130222.GA24346@lst.de> <20190119140452.GA25198@lst.de>
 <bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de>
Message-ID: <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de>
Date: Wed, 23 Jan 2019 15:34:55 +0100
MIME-Version: 1.0
In-Reply-To: <bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Hi Christoph,

I also compiled a kernel (zImage) for the X1000  from your Git 
'powerpc-dma.6-debug' (both patches) today.

It boots and the P.A. Semi Ethernet works!

I will test just the first patch tomorrow.

Thanks,
Christian


On 21 January 2019 at 3:38PM, Christian Zigotzky wrote:
> Hello Christoph,
>
> Thanks for your reply. I successfully compiled a kernel (uImage) for 
> the X5000 from your Git 'powerpc-dma.6-debug' (both patches) today.
>
> It detects the SATA hard disk drive and boots without any problems.
>
