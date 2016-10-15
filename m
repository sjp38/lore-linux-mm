Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDE16B0038
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 12:54:08 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 128so144684329pfz.1
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 09:54:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id x123si19909081pgb.17.2016.10.15.09.54.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 09:54:07 -0700 (PDT)
Date: Sat, 15 Oct 2016 09:54:05 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3] mm: vmalloc: Replace purge_lock spinlock with atomic
 refcount
Message-ID: <20161015165405.GA31568@infradead.org>
References: <1476535979-27467-1-git-send-email-joelaf@google.com>
 <20161015164613.GA26079@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161015164613.GA26079@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, Chris Wilson <chris@chris-wilson.co.uk>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

And now with a proper changelog, and the accidentall dropped call to
flush_tlb_kernel_range reinstated:

---
