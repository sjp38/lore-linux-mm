Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0F89800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 09:51:15 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v14so2356811wmd.3
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 06:51:15 -0800 (PST)
Received: from smtp1.de.adit-jv.com (smtp1.de.adit-jv.com. [62.225.105.245])
        by mx.google.com with ESMTPS id s3si298123wme.24.2018.01.24.06.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 06:51:14 -0800 (PST)
Date: Wed, 24 Jan 2018 15:51:03 +0100
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: Re: [PATCH v2 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180124145103.GA32426@vmlxhi-102.adit-jv.com>
References: <20180121144753.3109-1-erosca@de.adit-jv.com>
 <20180121144753.3109-2-erosca@de.adit-jv.com>
 <20180122012156.GA10428@bombadil.infradead.org>
 <20180122202530.GA24724@vmlxhi-102.adit-jv.com>
 <20180123004551.GA7817@bombadil.infradead.org>
 <20180123190036.GA16904@vmlxhi-102.adit-jv.com>
 <20180123202700.GA5565@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180123202700.GA5565@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 23, 2018 at 12:27:00PM -0800, Matthew Wilcox wrote:
> On Tue, Jan 23, 2018 at 08:00:36PM +0100, Eugeniu Rosca wrote:
> > Hi Matthew,
> > 
> > On Mon, Jan 22, 2018 at 04:45:51PM -0800, Matthew Wilcox wrote:
> > > On Mon, Jan 22, 2018 at 09:25:30PM +0100, Eugeniu Rosca wrote:
> > > > Here is what I came up with, based on your proposal:
> > > 
> > > Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Apologies for not knowing the process. Should I include the
> > `Reviewed-by` in the description of the next patch or will it be
> > done by the maintainer who will hopefully pick up the patch?
> 
> It's OK to not know the process ;-)
> 
> The next step is for you to integrate the changes you made here into a
> fresh patch against mainline, and then add my Reviewed-by: tag underneath
> your Signed-off-by: line.

[PATCH v3] pushed to https://marc.info/?l=linux-mm&m=151680461529468&w=2
Thanks for your support!

Best regards,
Eugeniu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
