Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65B586B0005
	for <linux-mm@kvack.org>; Tue, 15 May 2018 05:22:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y13-v6so11240729wrl.8
        for <linux-mm@kvack.org>; Tue, 15 May 2018 02:22:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t2-v6si480446edq.113.2018.05.15.02.22.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 02:22:40 -0700 (PDT)
Subject: Re: [PATCH v5 11/17] mm: Improve struct page documentation
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504183318.14415-12-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <223e471c-9425-ce62-a39b-daa69d2a0277@suse.cz>
Date: Tue, 15 May 2018 11:22:39 +0200
MIME-Version: 1.0
In-Reply-To: <20180504183318.14415-12-willy@infradead.org>
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
> Rewrite the documentation to describe what you can use in struct
> page rather than what you can't.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Reviewed-by: Randy Dunlap <rdunlap@infradead.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
