Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AEBF46B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 19:14:03 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o7HNDxgp001201
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 16:14:00 -0700
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz9.hot.corp.google.com with ESMTP id o7HNDtgH015326
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 16:13:58 -0700
Received: by pwj4 with SMTP id 4so50032pwj.13
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 16:13:55 -0700 (PDT)
Date: Tue, 17 Aug 2010 16:13:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup 1/6] Slub: Force no inlining of debug functions
In-Reply-To: <20100817211134.949705983@linux.com>
Message-ID: <alpine.DEB.2.00.1008171613100.1563@chino.kir.corp.google.com>
References: <20100817211118.958108012@linux.com> <20100817211134.949705983@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, Christoph Lameter wrote:

> Compiler folds the debgging functions into the critical paths.
> Avoid that by adding noinline to the functions that check for
> problems.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

This certainly generates better code for __slab_alloc() and __slab_free().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
