Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 225318E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:36:55 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id bj3so1823952plb.17
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 07:36:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y13si3510732pgj.157.2019.01.15.07.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 Jan 2019 07:36:53 -0800 (PST)
Date: Tue, 15 Jan 2019 07:36:52 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 4/9] riscv/vdso: don't clear PG_reserved
Message-ID: <20190115153652.GD26443@infradead.org>
References: <20190114125903.24845-1-david@redhat.com>
 <20190114125903.24845-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190114125903.24845-5-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org, Albert Ou <aou@eecs.berkeley.edu>, Andrew Morton <akpm@linux-foundation.org>, Palmer Dabbelt <palmer@sifive.com>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mediatek@lists.infradead.org, linux-riscv@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, Tobias Klauser <tklauser@distanz.ch>, linux-arm-kernel@lists.infradead.org

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
