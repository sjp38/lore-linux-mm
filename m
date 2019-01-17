Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4544C8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:21:19 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 144so103862wme.5
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 01:21:19 -0800 (PST)
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::3])
        by mx.google.com with ESMTPS id o6si16147257wrw.65.2019.01.17.01.21.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 01:21:17 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
References: <71A251A5-FA06-4019-B324-7AED32F7B714@xenosoft.de>
 <1b0c5c21-2761-d3a3-651b-3687bb6ae694@xenosoft.de>
 <3504ee70-02de-049e-6402-2d530bf55a84@xenosoft.de>
 <23284859-bf0a-9cd5-a480-2a7fd7802056@xenosoft.de>
 <075f70e3-7a4a-732f-b501-05a1a8e3c853@xenosoft.de>
 <b04d08ea-61f9-3212-b9a3-ad79e3b8bd05@xenosoft.de>
 <21f72a6a-9095-7034-f169-95e876228b2a@xenosoft.de>
 <27148ac2-2a92-5536-d886-2c0971ab43d9@xenosoft.de>
 <20190115133558.GA29225@lst.de>
 <685f0c06-af1b-0bec-ac03-f9bf1f7a2b35@xenosoft.de>
 <20190115151732.GA2325@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <e9345547-4dc6-747a-29ec-6375dc8bfe83@xenosoft.de>
Date: Thu, 17 Jan 2019 10:21:11 +0100
MIME-Version: 1.0
In-Reply-To: <20190115151732.GA2325@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Hi All,

I compiled the fixed '257002094bc5935dd63207a380d9698ab81f0775' 
(powerpc/dma: use the dma-direct allocator for coherent platforms) today.

git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a

git checkout 257002094bc5935dd63207a380d9698ab81f0775

Link to the Git: 
http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6 


env LANG=C make CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc zImage

env LANG=C make CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc uImage

The X1000 boots and the PASEMI onboard ethernet works!

Bad news for the X5000 (P5020 board). U-Boot loads the kernel and the 
dtb file. Then the kernel starts but it doesn't find any hard disks 
(partitions).

Cheers,
Christian


On 15 January 2019 at 4:17PM, Christoph Hellwig wrote:

So 257002094bc5935dd63207a380d9698ab81f0775 above is the fixed version
for the commit - this switched the ifdef in dma.c around that I had
inverted.  Can you try that one instead?  And then move on with the
commits after it in the updated powerpc-dma.6 branch - they are
identical to the original branch except for carrying this fix forward.
