Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B34256B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 10:33:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p189-v6so10744714pfp.2
        for <linux-mm@kvack.org>; Mon, 14 May 2018 07:33:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g13-v6si7838299pgn.146.2018.05.14.07.33.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 May 2018 07:33:06 -0700 (PDT)
Subject: Re: [PATCH v5 02/17] mm: Split page_type out from _mapcount
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504183318.14415-3-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fdf71f6e-d3a7-343f-b9af-652dbdb90eeb@suse.cz>
Date: Mon, 14 May 2018 16:33:01 +0200
MIME-Version: 1.0
In-Reply-To: <20180504183318.14415-3-willy@infradead.org>
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
> We're already using a union of many fields here, so stop abusing the
> _mapcount and make page_type its own field.  That implies renaming some
> of the machinery that creates PageBuddy, PageBalloon and PageKmemcg;
> bring back the PG_buddy, PG_balloon and PG_kmemcg names.
> 
> As suggested by Kirill, make page_type a bitmask.  Because it starts out
> life as -1 (thanks to sharing the storage with _mapcount), setting a
> page flag means clearing the appropriate bit.  This gives us space for
> probably twenty or so extra bits (depending how paranoid we want to be
> about _mapcount underflow).
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
