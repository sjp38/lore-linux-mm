Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06C7C8E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 06:52:59 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id v24so8021945wrd.23
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 03:52:58 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::12])
        by mx.google.com with ESMTPS id 21si20976380wmw.118.2019.01.19.03.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Jan 2019 03:52:57 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
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
 <e11e61b1-6468-122e-fc2b-3b3f857186bb@xenosoft.de>
 <f39d4fc6-7e4e-9132-c03f-59f1b52260e0@xenosoft.de>
Message-ID: <b9e5e081-a3cc-2625-4e08-2d55c2ba224b@xenosoft.de>
Date: Sat, 19 Jan 2019 12:52:52 +0100
MIME-Version: 1.0
In-Reply-To: <f39d4fc6-7e4e-9132-c03f-59f1b52260e0@xenosoft.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Hi Christoph,

I have found a small workaround. If I add 'mem=3500M' to the boot 
arguments then it detects the SATA hard disk and boots without any problems.

X5000> setenv bootargs root=/dev/sda2 console=ttyS0,115200 mem=3500M

Cheers,
Christian


On 19 January 2019 at 12:40PM, Christian Zigotzky wrote:
> Hi Christoph,
>
> I bought a USB null modem RS-232 serial cable today so I was able to 
> get some SATA error messages.
>
> Error messages:
>
> [   13.468538] fsl-sata ffe220000.sata: Sata FSL Platform/CSB Driver init
> [   13.475106] fsl-sata ffe220000.sata: failed to start port 0 
> (errno=-12)
> [   13.481736] fsl-sata ffe221000.sata: Sata FSL Platform/CSB Driver init
> [   13.488267] fsl-sata ffe221000.sata: failed to start port 0 
> (errno=-12)
>
> ---
>
> errno=-12 = Out of memory
>
> Please find attached the complete serial log.
>
> Cheers,
> Christian
>
>
> On 18 January 2019 at 4:06PM, Christian Zigotzky wrote:
>> Hello Christoph,
>>
>> I was able to compile 257002094bc5935dd63207a380d9698ab81f0775 from 
>> your Git powerpc-dma.6-debug today.
>>
>> Unfortunately I don't see any error messages (kernel ring buffer) and 
>> I don't have a RS232 serial null modem cable to get them.
>>
>> Cheers,
>> Christian
>>
>>
>
