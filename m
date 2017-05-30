Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E670B6B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 17:50:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h76so114964142pfh.15
        for <linux-mm@kvack.org>; Tue, 30 May 2017 14:50:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d34si46708575pld.139.2017.05.30.14.50.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 14:50:32 -0700 (PDT)
Date: Tue, 30 May 2017 14:50:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/6] mm: vmscan: delete unused pgdat_reclaimable_pages()
Message-Id: <20170530145029.59cef9048c3c254c9357eff1@linux-foundation.org>
In-Reply-To: <20170530181724.27197-2-hannes@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
	<20170530181724.27197-2-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, 30 May 2017 14:17:19 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> -extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);

Josef's "mm: make kswapd try harder to keep active pages in cache"
added a new callsite.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
