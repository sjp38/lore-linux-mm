Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2B306B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 10:37:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o23-v6so11387647pll.12
        for <linux-mm@kvack.org>; Mon, 14 May 2018 07:37:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6-v6si7936308pgc.262.2018.05.14.07.37.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 May 2018 07:37:55 -0700 (PDT)
Subject: Re: [PATCH v5 04/17] mm: Switch s_mem and slab_cache in struct page
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504183318.14415-5-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7b9bcc8b-b07e-b037-61a1-884b1d302ce5@suse.cz>
Date: Mon, 14 May 2018 16:37:52 +0200
MIME-Version: 1.0
In-Reply-To: <20180504183318.14415-5-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 05/04/2018 08:33 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This will allow us to store slub's counters in the same bits as slab's
> s_mem.  slub now needs to set page->mapping to NULL as it frees the page,
> just like slab does.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
