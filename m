Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B12628026B
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 21:38:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 21so422514141pfy.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 18:38:47 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id t9si27252876pal.288.2016.09.26.18.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 18:38:46 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id 6so9845149pfl.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 18:38:46 -0700 (PDT)
Message-ID: <1474940324.28155.44.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Sep 2016 18:38:44 -0700
In-Reply-To: <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
References: <20160922164359.9035-1-vbabka@suse.cz>
	 <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org

On Mon, 2016-09-26 at 17:01 -0700, Andrew Morton wrote:

> I don't share Eric's concerns about performance here.  If the vmalloc()
> is called, we're about to write to that quite large amount of memory
> which we just allocated, and the vmalloc() overhead will be relatively
> low.

I did not care of the performance of this particular select() system
call really, but other cpus because of more TLB invalidations.

At least CONFIG_DEBUG_PAGEALLOC=y builds should be impacted, but maybe
we do not care.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
