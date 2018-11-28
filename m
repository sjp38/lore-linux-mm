Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17D0A6B4ED5
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 15:35:15 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id v79so17769465pfd.20
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 12:35:15 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si8988377pfn.212.2018.11.28.12.35.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 12:35:13 -0800 (PST)
Date: Wed, 28 Nov 2018 21:35:10 +0100
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181128213510.543259e3@kitsune.suse.cz>
In-Reply-To: <535776df-dea3-eb26-6bf3-83f225e977df@xenosoft.de>
References: <20181114082314.8965-1-hch@lst.de>
	<20181127074253.GB30186@lst.de>
	<87zhttfonk.fsf@concordia.ellerman.id.au>
	<535776df-dea3-eb26-6bf3-83f225e977df@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Christoph Hellwig <hch@lst.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Wed, 28 Nov 2018 16:55:30 +0100
Christian Zigotzky <chzigotzky@xenosoft.de> wrote:

> On 28 November 2018 at 12:05PM, Michael Ellerman wrote:
> > Nothing specific yet.
> >
> > I'm a bit worried it might break one of the many old obscure platforms
> > we have that aren't well tested.
> >  
> Please don't apply the new DMA mapping code if you don't be sure if it 
> works on all supported PowerPC machines. Is the new DMA mapping code 
> really necessary? It's not really nice, to rewrote code if the old code 
> works perfect. We must not forget, that we work for the end users. Does 
> the end user have advantages with this new code? Is it faster? The old 
> code works without any problems. 

There is another service provided to the users as well: new code that is
cleaner and simpler which allows easier bug fixes and new features.
Without being familiar with the DMA mapping code I cannot really say if
that's the case here.

> I am also worried about this code. How 
> can I test this new DMA mapping code?

I suppose if your machine works it works for you.

Thanks

Michal
