Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 32BE58E0001
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 11:52:00 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id e1so4694708wmg.0
        for <linux-mm@kvack.org>; Sun, 16 Dec 2018 08:52:00 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k1si6735916wrq.448.2018.12.16.08.51.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Dec 2018 08:51:58 -0800 (PST)
Date: Sun, 16 Dec 2018 17:51:57 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181216165157.GA14652@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

FYI, given that we are one week before the expected 4.20 release
date and I haven't found the bug plaging Christians setups I think
we need to defer most of this to the next merge window.

I'd still like to get a few bits in earlier, which I will send out
separately now.
