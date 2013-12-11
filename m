Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id ADF3C6B0039
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:47:45 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so5645824yha.21
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:47:45 -0800 (PST)
Received: from mail-yh0-x22c.google.com (mail-yh0-x22c.google.com [2607:f8b0:4002:c01::22c])
        by mx.google.com with ESMTPS id b7si19358406yhm.285.2013.12.11.14.47.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 14:47:44 -0800 (PST)
Received: by mail-yh0-f44.google.com with SMTP id f64so5687370yha.17
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:47:44 -0800 (PST)
Date: Wed, 11 Dec 2013 14:47:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: blk-mq: uses page->list incorrectly
In-Reply-To: <20131211223632.8B2DFD41@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.02.1312111447280.7354@chino.kir.corp.google.com>
References: <20131211223631.51094A3D@viggo.jf.intel.com> <20131211223632.8B2DFD41@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@gentwo.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, akpm@linux-foundation.org

On Wed, 11 Dec 2013, Dave Hansen wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> 'struct page' has two list_head fields: 'lru' and 'list'.
> Conveniently, they are unioned together.  This means that code
> can use them interchangably, which gets horribly confusing.
> 
> The blk-mq made the logical decision to try to use page->list.
> But, that field was actually introduced just for the slub code.
> ->lru is the right field to use outside of slab/slub.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
