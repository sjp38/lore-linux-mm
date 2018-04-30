Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6346C6B0006
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 06:04:50 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u12-v6so2579256lfu.10
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 03:04:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q26-v6sor907049lfc.34.2018.04.30.03.04.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 03:04:48 -0700 (PDT)
Date: Mon, 30 Apr 2018 12:40:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 06/14] mm: Move _refcount out of struct page union
Message-ID: <20180430094016.paavpotmsyib2b6c@kshutemo-mobl1>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-7-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418184912.2851-7-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Apr 18, 2018 at 11:49:04AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Keeping the refcount in the union only encourages people to put
> something else in the union which will overlap with _refcount and
> eventually explode messily.  pahole reports no fields change location.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
