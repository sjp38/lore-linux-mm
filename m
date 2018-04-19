Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B30206B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:37:03 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c56-v6so4876472wrc.5
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:37:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s20si1426868edd.241.2018.04.19.04.37.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 04:37:02 -0700 (PDT)
Subject: Re: [PATCH v3 06/14] mm: Move _refcount out of struct page union
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-7-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1e1f20b2-f9a9-c9f3-96d7-b2846fb05f52@suse.cz>
Date: Thu, 19 Apr 2018 13:37:00 +0200
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-7-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Keeping the refcount in the union only encourages people to put
> something else in the union which will overlap with _refcount and
> eventually explode messily.  pahole reports no fields change location.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
