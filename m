Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id AC9926B00E0
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 12:55:01 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so5857912wib.10
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 09:55:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id eh3si16600610wib.85.2015.01.06.09.54.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 09:55:00 -0800 (PST)
Date: Tue, 6 Jan 2015 12:54:43 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: Dirty pages underflow on 3.14.23
In-Reply-To: <20150106150250.GA26895@phnom.home.cmpxchg.org>
Message-ID: <alpine.LRH.2.02.1501061246400.16437@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1501051744020.5119@file01.intranet.prod.int.rdu2.redhat.com> <20150106150250.GA26895@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Leon Romanovsky <leon@leon.nu>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Tue, 6 Jan 2015, Johannes Weiner wrote:

> > The bug probably happened during git pull or apt-get update, though one 
> > can't be sure that these commands caused it.
> > 
> > I see that 3.14.24 containes some fix for underflow (commit 
> > 6619741f17f541113a02c30f22a9ca22e32c9546, upstream commit 
> > abe5f972912d086c080be4bde67750630b6fb38b), but it doesn't seem that that 
> > commit fixes this condition. If you have a commit that could fix this, say 
> > it.
> 
> That's an unrelated counter, but there is a known dirty underflow
> problem that was addressed in 87a7e00b206a ("mm: protect
> set_page_dirty() from ongoing truncation").  It should make it into
> the stable kernels in the near future.  Can you reproduce this issue?
> 
> Thanks,
> Johannes

I can't reprodce it. It happened just once.

That patch is supposed to fix an occasional underflow by a single page - 
while my meminfo showed underflow by 22952KiB (5738 pages).

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
