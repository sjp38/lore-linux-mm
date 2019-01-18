Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0AFFE8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 07:08:03 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id l17so1583782wme.1
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 04:08:02 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::7])
        by mx.google.com with ESMTPS id 128si27176498wmd.69.2019.01.18.04.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 04:08:01 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
References: <075f70e3-7a4a-732f-b501-05a1a8e3c853@xenosoft.de>
 <b04d08ea-61f9-3212-b9a3-ad79e3b8bd05@xenosoft.de>
 <21f72a6a-9095-7034-f169-95e876228b2a@xenosoft.de>
 <27148ac2-2a92-5536-d886-2c0971ab43d9@xenosoft.de>
 <20190115133558.GA29225@lst.de>
 <685f0c06-af1b-0bec-ac03-f9bf1f7a2b35@xenosoft.de>
 <20190115151732.GA2325@lst.de>
 <e9345547-4dc6-747a-29ec-6375dc8bfe83@xenosoft.de>
 <20190118083539.GA30479@lst.de>
 <871403f2-fa7d-de15-89eb-070432e15c69@xenosoft.de>
 <20190118112842.GA9115@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <a2ca0118-5915-8b1c-7cfa-71cb4b43eaa6@xenosoft.de>
Date: Fri, 18 Jan 2019 13:07:54 +0100
MIME-Version: 1.0
In-Reply-To: <20190118112842.GA9115@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a

git checkout 257002094bc5935dd63207a380d9698ab81f0775


I get the following error message with your patch:

patching file a/kernel/dma/direct.c
Hunk #1 FAILED at 118.
Hunk #2 FAILED at 139.
2 out of 2 hunks FAILED -- saving rejects to file a/kernel/dma/direct.c.rej

-- Christian

On 18 January 2019 at 12:28PM, Christoph Hellwig wrote:
> On Fri, Jan 18, 2019 at 12:10:26PM +0100, Christian Zigotzky wrote:
>> For which commit?
> On top of 257002094bc5935dd63207a380d9698ab81f0775, that is the first
> one you identified as breaking the detection of the SATA disks.
>
