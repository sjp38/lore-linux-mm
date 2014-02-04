Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id F32946B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 21:01:02 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so7831853pbc.14
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 18:01:02 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id oq9si22592425pac.64.2014.02.03.18.01.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 18:01:02 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so7819958pab.40
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 18:01:00 -0800 (PST)
Date: Mon, 3 Feb 2014 18:00:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: avoid isolating pinned pages fix
In-Reply-To: <20140204015332.GA14779@lge.com>
Message-ID: <alpine.DEB.2.02.1402031755440.26347@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com> <20140203095329.GH6732@suse.de> <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com> <20140204000237.GA17331@lge.com> <alpine.DEB.2.02.1402031610090.10778@chino.kir.corp.google.com>
 <20140204015332.GA14779@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 4 Feb 2014, Joonsoo Kim wrote:

> Okay. It can't fix your situation. Anyway, *normal* anon pages may be mapped
> and have positive page_count(), so your code such as
> '!page_mapping(page) && page_count(page)' makes compaction skip these *normal*
> anon pages and this is incorrect behaviour.
> 

So how does that work with migrate_page_move_mapping() which demands 
page_count(page) == 1 and the get_page_unless_zero() in 
__isolate_lru_page()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
