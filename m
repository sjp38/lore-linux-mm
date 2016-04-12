Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 802036B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:37:55 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id f1so90960861igr.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 08:37:55 -0700 (PDT)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id mc7si21834444igb.48.2016.04.12.08.37.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 08:37:54 -0700 (PDT)
Received: by mail-io0-x236.google.com with SMTP id u185so33064889iod.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 08:37:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160412082838.4ce17c1a@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160407143854.GA7685@infradead.org>
	<570678B7.7010802@sandisk.com>
	<570A9F5B.5010600@grimberg.me>
	<20160411234157.3fc9c6fe@redhat.com>
	<CAKgT0UdbO00-Pe3xdrCC2T8L=XVZasWSQQVzTTs9r521RDes+Q@mail.gmail.com>
	<20160412082838.4ce17c1a@redhat.com>
Date: Tue, 12 Apr 2016 08:37:54 -0700
Message-ID: <CAKgT0Uf7qsqYXq=GfCehcEpMRn2t6TyM50h_NFvDQnOoemfsbw@mail.gmail.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
From: Alexander Duyck <alexander.duyck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Sagi Grimberg <sagi@grimberg.me>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Bart Van Assche <bart.vanassche@sandisk.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On Mon, Apr 11, 2016 at 11:28 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Mon, 11 Apr 2016 15:02:51 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> Have you taken a look at possibly trying to optimize the DMA pool API
>> to work with pages?  It sounds like it is supposed to do something
>> similar to what you are wanting to do.
>
> Yes, I have looked at the mm/dmapool.c API. AFAIK this is for DMA
> coherent memory (see use of dma_alloc_coherent/dma_free_coherent).
>
> What we are doing is "streaming" DMA memory, when processing the RX
> ring.
>
> (NIC are only using DMA coherent memory for the descriptors, which are
> allocated on driver init)

Yes, I know that but it shouldn't take much to extend the API to
provide the option for a streaming DMA mapping.  That was why I
thought you might want to look in this direction.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
