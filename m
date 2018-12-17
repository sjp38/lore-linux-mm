Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C69FB8E0001
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 20:14:57 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d71so9158048pgc.1
        for <linux-mm@kvack.org>; Sun, 16 Dec 2018 17:14:57 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id e15si5566584pgg.281.2018.12.16.17.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 16 Dec 2018 17:14:56 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: use generic DMA mapping code in powerpc V4
In-Reply-To: <20181216165157.GA14652@lst.de>
References: <20181114082314.8965-1-hch@lst.de> <20181216165157.GA14652@lst.de>
Date: Mon, 17 Dec 2018 12:14:47 +1100
Message-ID: <87d0q1uf7c.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Christoph Hellwig <hch@lst.de> writes:

> FYI, given that we are one week before the expected 4.20 release
> date and I haven't found the bug plaging Christians setups I think
> we need to defer most of this to the next merge window.

OK, sorry I couldn't help. I tried powering up my pasemi board last week
but it just gives me a couple of status leds and nothing else, the fan
never spins up.

> I'd still like to get a few bits in earlier, which I will send out
> separately now.

OK.

cheers
