Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8CDEE6B0035
	for <linux-mm@kvack.org>; Sat, 25 Jan 2014 23:41:48 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id na10so2164429bkb.14
        for <linux-mm@kvack.org>; Sat, 25 Jan 2014 20:41:47 -0800 (PST)
Received: from mail-bk0-x231.google.com (mail-bk0-x231.google.com [2a00:1450:4008:c01::231])
        by mx.google.com with ESMTPS id yt2si9128458bkb.222.2014.01.25.20.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Jan 2014 20:41:47 -0800 (PST)
Received: by mail-bk0-f49.google.com with SMTP id v15so2109440bkz.8
        for <linux-mm@kvack.org>; Sat, 25 Jan 2014 20:41:46 -0800 (PST)
Date: Sat, 25 Jan 2014 20:41:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [linux-next][PATCH] mm: slub: work around unneeded lockdep
 warning
In-Reply-To: <20140124152023.A450E599@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.02.1401252041120.10325@chino.kir.corp.google.com>
References: <20140124152023.A450E599@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, penberg@kernel.org, linux@arm.linux.org.uk

On Fri, 24 Jan 2014, Dave Hansen wrote:

> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The slub code does some setup during early boot in
> early_kmem_cache_node_alloc() with some local data.  There is no
> possible way that another CPU can see this data, so the slub code
> doesn't unnecessarily lock it.  However, some new lockdep asserts
> check to make sure that add_partial() _always_ has the list_lock
> held.
> 
> Just add the locking, even though it is technically unnecessary.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Russell King <linux@arm.linux.org.uk>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
