Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 097576B002F
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:47:31 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e22-v6so4865030ita.0
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:47:31 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id y6-v6si1985802itd.110.2018.04.10.13.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 13:47:30 -0700 (PDT)
Date: Tue, 10 Apr 2018 15:47:28 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Remove use of page->counter
In-Reply-To: <20180410195429.GB21336@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804101545350.30437@nuc-kabylake>
References: <20180410195429.GB21336@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On Tue, 10 Apr 2018, Matthew Wilcox wrote:

> In my continued attempt to clean up struct page, I've got to the point
> where it'd be really nice to get rid of 'counters'.  I like the patch
> below because it makes it clear when & where we're doing "weird" things
> to access the various counters.

Well sounds good.

> struct {
> 	unsigned long flags;
> 	union {
> 		struct {
> 			struct address_space *mapping;
> 			pgoff_t index;
> 		};
> 		struct {
> 			void *s_mem;
> 			void *freelist;
> 		};
> 		...
> 	};
> 	union {
> 		atomic_t _mapcount;
> 		unsigned int active;

Is this aligned on a doubleword boundary? Maybe move the refcount below
the flags field?
