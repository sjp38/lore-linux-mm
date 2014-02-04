Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7146B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 21:15:35 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so7840895pbc.13
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 18:15:35 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id l8si22609105pao.268.2014.02.03.18.15.31
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 18:15:33 -0800 (PST)
Date: Tue, 4 Feb 2014 11:15:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch] mm, compaction: avoid isolating pinned pages fix
Message-ID: <20140204021533.GA14924@lge.com>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com>
 <20140203095329.GH6732@suse.de>
 <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com>
 <20140204000237.GA17331@lge.com>
 <alpine.DEB.2.02.1402031610090.10778@chino.kir.corp.google.com>
 <20140204015332.GA14779@lge.com>
 <alpine.DEB.2.02.1402031755440.26347@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402031755440.26347@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Feb 03, 2014 at 06:00:56PM -0800, David Rientjes wrote:
> On Tue, 4 Feb 2014, Joonsoo Kim wrote:
> 
> > Okay. It can't fix your situation. Anyway, *normal* anon pages may be mapped
> > and have positive page_count(), so your code such as
> > '!page_mapping(page) && page_count(page)' makes compaction skip these *normal*
> > anon pages and this is incorrect behaviour.
> > 
> 
> So how does that work with migrate_page_move_mapping() which demands 
> page_count(page) == 1 and the get_page_unless_zero() in 
> __isolate_lru_page()?

Before doing migrate_page_move_mapping(), try_to_unmap() is called so that all
mapping is unmapped. Then, remained page_count() is 1 which is grabbed by
__isolate_lru_page(). Am I missing something?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
