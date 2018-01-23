Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB4F6800DD
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 15:27:11 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id g37so1047120uah.13
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:27:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i6si2480399vkb.368.2018.01.23.12.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jan 2018 12:27:10 -0800 (PST)
Date: Tue, 23 Jan 2018 12:27:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180123202700.GA5565@bombadil.infradead.org>
References: <20180121144753.3109-1-erosca@de.adit-jv.com>
 <20180121144753.3109-2-erosca@de.adit-jv.com>
 <20180122012156.GA10428@bombadil.infradead.org>
 <20180122202530.GA24724@vmlxhi-102.adit-jv.com>
 <20180123004551.GA7817@bombadil.infradead.org>
 <20180123190036.GA16904@vmlxhi-102.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123190036.GA16904@vmlxhi-102.adit-jv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugeniu Rosca <erosca@de.adit-jv.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 23, 2018 at 08:00:36PM +0100, Eugeniu Rosca wrote:
> Hi Matthew,
> 
> On Mon, Jan 22, 2018 at 04:45:51PM -0800, Matthew Wilcox wrote:
> > On Mon, Jan 22, 2018 at 09:25:30PM +0100, Eugeniu Rosca wrote:
> > > Here is what I came up with, based on your proposal:
> > 
> > Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Apologies for not knowing the process. Should I include the
> `Reviewed-by` in the description of the next patch or will it be
> done by the maintainer who will hopefully pick up the patch?

It's OK to not know the process ;-)

The next step is for you to integrate the changes you made here into a
fresh patch against mainline, and then add my Reviewed-by: tag underneath
your Signed-off-by: line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
