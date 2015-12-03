Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 818236B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 20:24:47 -0500 (EST)
Received: by pacej9 with SMTP id ej9so56209028pac.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 17:24:47 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id o82si8254767pfa.139.2015.12.02.17.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 17:24:46 -0800 (PST)
Received: by padhx2 with SMTP id hx2so56191208pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 17:24:46 -0800 (PST)
Date: Wed, 2 Dec 2015 17:24:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm/page_alloc.c: use list_for_each_entry in
 mark_free_pages()
In-Reply-To: <7009a8fa2dba33da9bcfe60db4741139c07c8074.1449068845.git.geliangtang@163.com>
Message-ID: <alpine.DEB.2.10.1512021724330.17205@chino.kir.corp.google.com>
References: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com> <7009a8fa2dba33da9bcfe60db4741139c07c8074.1449068845.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <js1304@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2 Dec 2015, Geliang Tang wrote:

> Use list_for_each_entry instead of list_for_each + list_entry to
> simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
