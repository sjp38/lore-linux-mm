Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57D3B800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 19:46:07 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id n28so17356851qtk.7
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 16:46:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v201si735781qka.359.2018.01.22.16.46.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Jan 2018 16:46:05 -0800 (PST)
Date: Mon, 22 Jan 2018 16:45:51 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180123004551.GA7817@bombadil.infradead.org>
References: <20180121144753.3109-1-erosca@de.adit-jv.com>
 <20180121144753.3109-2-erosca@de.adit-jv.com>
 <20180122012156.GA10428@bombadil.infradead.org>
 <20180122202530.GA24724@vmlxhi-102.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180122202530.GA24724@vmlxhi-102.adit-jv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugeniu Rosca <erosca@de.adit-jv.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 22, 2018 at 09:25:30PM +0100, Eugeniu Rosca wrote:
> Here is what I came up with, based on your proposal:

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
