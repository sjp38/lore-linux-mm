Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D06C36B005C
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 11:17:35 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l8-v6so3920064qtb.11
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:17:35 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id h45-v6si5196520qta.264.2018.04.20.08.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 08:17:34 -0700 (PDT)
Date: Fri, 20 Apr 2018 10:17:32 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 02/14] mm: Split page_type out from _mapcount
In-Reply-To: <20180418184912.2851-3-willy@infradead.org>
Message-ID: <alpine.DEB.2.20.1804201014300.18006@nuc-kabylake>
References: <20180418184912.2851-1-willy@infradead.org> <20180418184912.2851-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 18 Apr 2018, Matthew Wilcox wrote:

> As suggested by Kirill, make page_type a bitmask.  Because it starts out
> life as -1 (thanks to sharing the storage with _mapcount), setting a
> page flag means clearing the appropriate bit.  This gives us space for
> probably twenty or so extra bits (depending how paranoid we want to be
> about _mapcount underflow).

Could we use bits in the page->flags for this? We could remove the node or
something else from page->flags. And the slab bit could also be part of
the page type.

The page field handling gets more and more bizarre.
