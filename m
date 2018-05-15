Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA866B026F
	for <linux-mm@kvack.org>; Tue, 15 May 2018 07:30:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p14-v6so11719593wre.21
        for <linux-mm@kvack.org>; Tue, 15 May 2018 04:30:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7-v6si109124ede.313.2018.05.15.04.30.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 04:30:32 -0700 (PDT)
Subject: Re: [PATCH v5 14/17] slab,slub: Remove rcu_head size checks
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504183318.14415-15-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d83ac206-4a1c-d0c0-1225-9e4f7d725b43@suse.cz>
Date: Tue, 15 May 2018 13:30:31 +0200
MIME-Version: 1.0
In-Reply-To: <20180504183318.14415-15-willy@infradead.org>
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
> rcu_head may now grow larger than list_head without affecting slab or
> slub.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Acked-by: Christoph Lameter <cl@linux.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
