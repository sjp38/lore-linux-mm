Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 643DA6B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:12:04 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so13183488pfx.1
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 03:12:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id l3si28116303pln.71.2017.01.18.03.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 03:12:03 -0800 (PST)
Date: Wed, 18 Jan 2017 03:12:01 -0800
From: willy@infradead.org
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Message-ID: <20170118111201.GB29472@bombadil.infradead.org>
References: <20170118110731.GA15949@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118110731.GA15949@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, Jan 18, 2017 at 03:07:32AM -0800, Paul E. McKenney wrote:
> A group of Linux kernel hackers reported chasing a bug that resulted
> from their assumption that SLAB_DESTROY_BY_RCU provided an existence
> guarantee, that is, that no block from such a slab would be reallocated
> during an RCU read-side critical section.  Of course, that is not the
> case.  Instead, SLAB_DESTROY_BY_RCU only prevents freeing of an entire
> slab of blocks.
> 
> However, there is a phrase for this, namely "type safety".  This commit
> therefore renames SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU in order
> to avoid future instances of this sort of confusion.

This is probably the ultimate in bikeshedding, but RCU is not the
thing which is providing the typesafety.  Slab is providing the
typesafety in order to help RCU.  So would a better name not be
'SLAB_TYPESAFETY_FOR_RCU', or more succinctly 'SLAB_RCU_TYPESAFE'?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
