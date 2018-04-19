Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE0936B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:03:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p4-v6so5247796wrf.17
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:03:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a12si3340969edj.89.2018.04.19.07.03.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 07:03:55 -0700 (PDT)
Subject: Re: [PATCH v3 11/14] mm: Combine first two unions in struct page
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-12-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0666c9e6-9b62-c083-6d45-56d77a3943ea@suse.cz>
Date: Thu, 19 Apr 2018 16:03:54 +0200
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-12-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This gives us five words of space in a single union in struct page.
> The compound_mapcount moves position (from offset 24 to offset 20)
> on 64-bit systems, but that does not seem likely to cause any trouble.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
