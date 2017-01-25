Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 920E86B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:25:45 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c206so40693306wme.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:25:45 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g126si224139wmg.6.2017.01.25.12.25.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 12:25:44 -0800 (PST)
Date: Wed, 25 Jan 2017 15:25:33 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Message-ID: <20170125202533.GA22138@cmpxchg.org>
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
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

This has come up in the past, and it always proved hard to agree on a
better name for it. But I like SLAB_TYPESAFE_BY_RCU the best out of
all proposals, and it's much more poignant than the current name.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
