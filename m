Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8EB56B0272
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:46:40 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b185-v6so11504963qkg.19
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:46:40 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id t13-v6si892698qto.159.2018.07.30.08.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 Jul 2018 08:46:40 -0700 (PDT)
Date: Mon, 30 Jul 2018 15:46:39 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 5/7] mm: rename and change semantics of
 nr_indirectly_reclaimable_bytes
In-Reply-To: <20180718133620.6205-6-vbabka@suse.cz>
Message-ID: <01000164ebdeb99c-01f9fc67-5d6e-4e03-b2d8-ab733e76427a-000000@email.amazonses.com>
References: <20180718133620.6205-1-vbabka@suse.cz> <20180718133620.6205-6-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vijayanand Jitta <vjitta@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>


Acked-by: Christoph Lameter <cl@linux.com>
