Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D89536B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 10:42:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k27-v6so9424488wre.23
        for <linux-mm@kvack.org>; Mon, 14 May 2018 07:42:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10-v6si1588041edc.243.2018.05.14.07.42.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 May 2018 07:42:55 -0700 (PDT)
Subject: Re: [PATCH v5 07/17] mm: Combine first three unions in struct page
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504183318.14415-8-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a673ca6a-07aa-43ef-91df-15e8210affe7@suse.cz>
Date: Mon, 14 May 2018 16:42:54 +0200
MIME-Version: 1.0
In-Reply-To: <20180504183318.14415-8-willy@infradead.org>
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
> By combining these three one-word unions into one three-word union,
> we make it easier for users to add their own multi-word fields to struct
> page, as well as making it obvious that SLUB needs to keep its double-word
> alignment for its freelist & counters.
> 
> No field moves position; verified with pahole.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
