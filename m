Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D607F6B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:08:56 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l19so2489703qkk.11
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:08:56 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id h39si3574028qtk.13.2018.04.16.08.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:08:55 -0700 (PDT)
Date: Mon, 16 Apr 2018 10:08:54 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Remove use of page->counter
In-Reply-To: <20180416135321.GD26022@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804161007450.8424@nuc-kabylake>
References: <20180410195429.GB21336@bombadil.infradead.org> <alpine.DEB.2.20.1804101545350.30437@nuc-kabylake> <20180410205757.GD21336@bombadil.infradead.org> <alpine.DEB.2.20.1804101702240.30842@nuc-kabylake> <20180411182606.GA22494@bombadil.infradead.org>
 <20180416135321.GD26022@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On Mon, 16 Apr 2018, Matthew Wilcox wrote:

> 		struct {	/* Slub */
> 			struct kmem_cache *slub_cache;
> 			/* Dword boundary */
> 			void *slub_freelist;
> 			unsigned short inuse;
> 			unsigned short objects:15;
> 			unsigned short frozen:1;
> 			struct page *next;
> #ifdef CONFIG_64BIT
> 			int pobjects;
> 			int pages;
> #endif
> 			short int pages;
> 			short int pobjects;
> #endif

That looks better.

> I'd want to change slob to use slob_list instead of ->lru.  Or maybe even do
> something radical like _naming_ the struct in the union so we don't have to
> manually namespace the names of the elements.

Hmmm... How would that look?
