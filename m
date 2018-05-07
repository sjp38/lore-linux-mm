Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 394C96B026B
	for <linux-mm@kvack.org>; Mon,  7 May 2018 10:58:53 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x30-v6so16765263qtm.20
        for <linux-mm@kvack.org>; Mon, 07 May 2018 07:58:53 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id r47-v6si1248284qtb.46.2018.05.07.07.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 07:58:52 -0700 (PDT)
Date: Mon, 7 May 2018 09:58:51 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v5 04/17] mm: Switch s_mem and slab_cache in struct
 page
In-Reply-To: <20180504183318.14415-5-willy@infradead.org>
Message-ID: <alpine.DEB.2.21.1805070958130.23585@nuc-kabylake>
References: <20180504183318.14415-1-willy@infradead.org> <20180504183318.14415-5-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

On Fri, 4 May 2018, Matthew Wilcox wrote:

> This will allow us to store slub's counters in the same bits as slab's
> s_mem.  slub now needs to set page->mapping to NULL as it frees the page,
> just like slab does.

Acked-by: Christoph Lameter <cl@linux.com>
