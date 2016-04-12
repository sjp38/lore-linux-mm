Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id CBA2E6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 02:28:46 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id f52so7940964qga.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 23:28:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 68si23187278qhx.75.2016.04.11.23.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 23:28:46 -0700 (PDT)
Date: Tue, 12 Apr 2016 08:28:38 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Message-ID: <20160412082838.4ce17c1a@redhat.com>
In-Reply-To: <CAKgT0UdbO00-Pe3xdrCC2T8L=XVZasWSQQVzTTs9r521RDes+Q@mail.gmail.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160407143854.GA7685@infradead.org>
	<570678B7.7010802@sandisk.com>
	<570A9F5B.5010600@grimberg.me>
	<20160411234157.3fc9c6fe@redhat.com>
	<CAKgT0UdbO00-Pe3xdrCC2T8L=XVZasWSQQVzTTs9r521RDes+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Sagi Grimberg <sagi@grimberg.me>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Bart Van Assche <bart.vanassche@sandisk.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com


On Mon, 11 Apr 2016 15:02:51 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:

> Have you taken a look at possibly trying to optimize the DMA pool API
> to work with pages?  It sounds like it is supposed to do something
> similar to what you are wanting to do.

Yes, I have looked at the mm/dmapool.c API. AFAIK this is for DMA
coherent memory (see use of dma_alloc_coherent/dma_free_coherent). 

What we are doing is "streaming" DMA memory, when processing the RX
ring.

(NIC are only using DMA coherent memory for the descriptors, which are
allocated on driver init)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
