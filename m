Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE3766B0007
	for <linux-mm@kvack.org>; Tue,  1 May 2018 12:46:12 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id q5so7910475uaj.0
        for <linux-mm@kvack.org>; Tue, 01 May 2018 09:46:12 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id u18-v6si4969396vkb.79.2018.05.01.09.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 May 2018 09:46:12 -0700 (PDT)
Date: Tue, 1 May 2018 11:46:10 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v4 15/16] slab,slub: Remove rcu_head size checks
In-Reply-To: <20180430202247.25220-16-willy@infradead.org>
Message-ID: <alpine.DEB.2.21.1805011145520.16325@nuc-kabylake>
References: <20180430202247.25220-1-willy@infradead.org> <20180430202247.25220-16-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

On Mon, 30 Apr 2018, Matthew Wilcox wrote:

> rcu_head may now grow larger than list_head without affecting slab or
> slub.

Acked-by: Christoph Lameter <cl@linux.com>
