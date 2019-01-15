Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05C088E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:17:36 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id o6so1007660wmf.0
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 07:17:35 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 6si52962968wrr.52.2019.01.15.07.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 07:17:33 -0800 (PST)
Date: Tue, 15 Jan 2019 16:17:32 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190115151732.GA2325@lst.de>
References: <71A251A5-FA06-4019-B324-7AED32F7B714@xenosoft.de> <1b0c5c21-2761-d3a3-651b-3687bb6ae694@xenosoft.de> <3504ee70-02de-049e-6402-2d530bf55a84@xenosoft.de> <23284859-bf0a-9cd5-a480-2a7fd7802056@xenosoft.de> <075f70e3-7a4a-732f-b501-05a1a8e3c853@xenosoft.de> <b04d08ea-61f9-3212-b9a3-ad79e3b8bd05@xenosoft.de> <21f72a6a-9095-7034-f169-95e876228b2a@xenosoft.de> <27148ac2-2a92-5536-d886-2c0971ab43d9@xenosoft.de> <20190115133558.GA29225@lst.de> <685f0c06-af1b-0bec-ac03-f9bf1f7a2b35@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <685f0c06-af1b-0bec-ac03-f9bf1f7a2b35@xenosoft.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On Tue, Jan 15, 2019 at 02:56:34PM +0100, Christian Zigotzky wrote:
> On 15 January 2019 at 2:35PM, Christoph Hellwig wrote:
>> On Tue, Jan 15, 2019 at 11:55:25AM +0100, Christian Zigotzky wrote:
>>> Next step: 21074ef03c0816ae158721a78cabe9035938dddd (powerpc/dma: use the
>>> generic direct mapping bypass)
>>>
>>> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>>>
>>> git checkout 21074ef03c0816ae158721a78cabe9035938dddd
>>>
>>> I was able to compile the kernel for the AmigaOne X1000 (Nemo board with PA
>>> Semi PA6T-1682M SoC). It boots but the PA Semi onboard ethernet doesn't
>>> work.
>> Thanks.  But we are exactly missing the steps that are relevant.  I've
>> pushed a fixed up powerpc-dma.6 tree, which will only change starting from
>> the first commit that didn't link.
>>
>> The first commit that changed from the old one is this one:
>>
>> http://git.infradead.org/users/hch/misc.git/commitdiff/257002094bc5935dd63207a380d9698ab81f0775
>>
>> which was that one that your compile failed on first.
>>
>> Thanks again for all your work!
>>
> Thank you! I tried the commit 240d7ecd7f6fa62e074e8a835e620047954f0b28 
> (powerpc/dma: use the dma-direct allocator for coherent platforms) again.
>
> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>
> git checkout 240d7ecd7f6fa62e074e8a835e620047954f0b28
>
> I modified the 'dma.c' patch because of the undefined references to 
> '__dma_nommu_free_coherent' and '__dma_nommu_alloc_coherent':

So 257002094bc5935dd63207a380d9698ab81f0775 above is the fixed version
for the commit - this switched the ifdef in dma.c around that I had
inverted.  Can you try that one instead?  And then move on with the
commits after it in the updated powerpc-dma.6 branch - they are
identical to the original branch except for carrying this fix forward.
