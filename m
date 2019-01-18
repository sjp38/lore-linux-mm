Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC57E8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 10:06:57 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id h11so6908008wrs.2
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 07:06:57 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::6])
        by mx.google.com with ESMTPS id r10si55906811wrl.456.2019.01.18.07.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 07:06:56 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
References: <20190115133558.GA29225@lst.de>
 <685f0c06-af1b-0bec-ac03-f9bf1f7a2b35@xenosoft.de>
 <20190115151732.GA2325@lst.de>
 <e9345547-4dc6-747a-29ec-6375dc8bfe83@xenosoft.de>
 <20190118083539.GA30479@lst.de>
 <871403f2-fa7d-de15-89eb-070432e15c69@xenosoft.de>
 <20190118112842.GA9115@lst.de>
 <a2ca0118-5915-8b1c-7cfa-71cb4b43eaa6@xenosoft.de>
 <20190118121810.GA13327@lst.de>
 <eceebeda-0e18-00f6-06e7-def2eb0aa961@xenosoft.de>
 <20190118125500.GA15657@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <e11e61b1-6468-122e-fc2b-3b3f857186bb@xenosoft.de>
Date: Fri, 18 Jan 2019 16:06:49 +0100
MIME-Version: 1.0
In-Reply-To: <20190118125500.GA15657@lst.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Hello Christoph,

I was able to compile 257002094bc5935dd63207a380d9698ab81f0775 from your 
Git powerpc-dma.6-debug today.

Unfortunately I don't see any error messages (kernel ring buffer) and I 
don't have a RS232 serial null modem cable to get them.

Cheers,
Christian
