Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27C4C6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 21:41:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a6so5973707pfn.3
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 18:41:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 97-v6si1471593plm.548.2018.04.09.18.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 18:41:54 -0700 (PDT)
Date: Mon, 9 Apr 2018 18:41:53 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 3/3] mm: restructure memfd code
Message-ID: <20180410014153.GB31282@bombadil.infradead.org>
References: <20180409230505.18953-1-mike.kravetz@oracle.com>
 <20180409230505.18953-4-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409230505.18953-4-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Apr 09, 2018 at 04:05:05PM -0700, Mike Kravetz wrote:
> +/*
> + * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
> + * so reuse a tag which we firmly believe is never set or cleared on shmem.
> + */
> +#define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE

Do we also firmly believe it's never used on hugetlbfs?
