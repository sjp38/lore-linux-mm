Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E57C8E00B5
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 08:37:44 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e17so3675201wrw.13
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 05:37:44 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::7])
        by mx.google.com with ESMTPS id n5si75150579wrh.320.2019.01.25.05.37.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 05:37:42 -0800 (PST)
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
 <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de>
Message-ID: <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de>
Date: Fri, 25 Jan 2019 14:37:34 +0100
MIME-Version: 1.0
In-Reply-To: <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Next step just with the first patch: 
5c532d07c2f3c3972104de505d06b8d85f403f06 (use powerpc zone selection)

git clone git://git.infradead.org/users/hch/misc.git -b 
powerpc-dma.6-debug a

git checkout 5c532d07c2f3c3972104de505d06b8d85f403f06

Link to the Git: 
http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6-debug

Results:

X5000: The kernel detects the SATA hard disk drive and boots without any 
problems.

X1000: The kernel boots and the P.A. Semi Ethernet works!

-- Christian


On 23 January 2019 at 3:34PM, Christian Zigotzky wrote:
> Hi Christoph,
>
> I also compiled a kernel (zImage) for the X1000  from your Git 
> 'powerpc-dma.6-debug' (both patches) today.
>
> It boots and the P.A. Semi Ethernet works!
>
> I will test just the first patch tomorrow.
>
> Thanks,
> Christian
>
>
> On 21 January 2019 at 3:38PM, Christian Zigotzky wrote:
>> Hello Christoph,
>>
>> Thanks for your reply. I successfully compiled a kernel (uImage) for 
>> the X5000 from your Git 'powerpc-dma.6-debug' (both patches) today.
>>
>> It detects the SATA hard disk drive and boots without any problems.
>>
>
>
