Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB1E86B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 18:02:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b84so263579wmh.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 15:02:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p91si10494894edp.334.2017.05.30.15.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 May 2017 15:02:51 -0700 (PDT)
Date: Tue, 30 May 2017 18:02:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/6] mm: vmscan: delete unused pgdat_reclaimable_pages()
Message-ID: <20170530220238.GA7731@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-2-hannes@cmpxchg.org>
 <20170530145029.59cef9048c3c254c9357eff1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530145029.59cef9048c3c254c9357eff1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, May 30, 2017 at 02:50:29PM -0700, Andrew Morton wrote:
> On Tue, 30 May 2017 14:17:19 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > -extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
> 
> Josef's "mm: make kswapd try harder to keep active pages in cache"
> added a new callsite.

Ah yes, I forgot you pulled that in. The next version of his patch
shouldn't need it anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
