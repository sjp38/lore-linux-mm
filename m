Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9FCA6B4D9B
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 10:55:53 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id o63-v6so2979222wma.2
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 07:55:53 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::10])
        by mx.google.com with ESMTPS id y3-v6si2552174wmg.193.2018.11.28.07.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 07:55:52 -0800 (PST)
Subject: Re: use generic DMA mapping code in powerpc V4
References: <20181114082314.8965-1-hch@lst.de> <20181127074253.GB30186@lst.de>
 <87zhttfonk.fsf@concordia.ellerman.id.au>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <535776df-dea3-eb26-6bf3-83f225e977df@xenosoft.de>
Date: Wed, 28 Nov 2018 16:55:30 +0100
MIME-Version: 1.0
In-Reply-To: <87zhttfonk.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Christoph Hellwig <hch@lst.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On 28 November 2018 at 12:05PM, Michael Ellerman wrote:
> Nothing specific yet.
>
> I'm a bit worried it might break one of the many old obscure platforms
> we have that aren't well tested.
>
Please don't apply the new DMA mapping code if you don't be sure if it 
works on all supported PowerPC machines. Is the new DMA mapping code 
really necessary? It's not really nice, to rewrote code if the old code 
works perfect. We must not forget, that we work for the end users. Does 
the end user have advantages with this new code? Is it faster? The old 
code works without any problems. I am also worried about this code. How 
can I test this new DMA mapping code?

Thanks
