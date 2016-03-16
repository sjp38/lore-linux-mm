Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2EACB6B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 16:37:05 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id u190so88564977pfb.3
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 13:37:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id q75si7205369pfq.207.2016.03.16.13.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Mar 2016 13:37:04 -0700 (PDT)
Date: Wed, 16 Mar 2016 13:36:57 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: Export symbols unmapped_area() &
 unmapped_area_topdown()
Message-ID: <20160316203657.GA29061@infradead.org>
References: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
 <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olu Ogunbowale <Olu.Ogunbowale@imgtec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Wed, Mar 16, 2016 at 05:10:34PM +0000, Olu Ogunbowale wrote:
> From: Olujide Ogunbowale <Olu.Ogunbowale@imgtec.com>
> 
> Export the memory management functions, unmapped_area() &
> unmapped_area_topdown(), as GPL symbols; this allows the kernel to
> better support process address space mirroring on both CPU and device
> for out-of-tree drivers by allowing the use of vm_unmapped_area() in a
> driver's file operation get_unmapped_area().

No new exports without in-tree drivers.  How about you get started
to get your drives into the tree first?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
