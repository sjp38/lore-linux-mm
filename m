Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 379656B01B0
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 12:23:17 -0400 (EDT)
Date: Wed, 9 Jun 2010 11:20:02 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 2/4] slub: rename debug_on to cache_debug_on
In-Reply-To: <alpine.DEB.2.00.1006082348160.30606@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006091119000.21686@router.home>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006082348160.30606@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, David Rientjes wrote:

> debug_on() is too generic of a name for a slub function, so rename it to
> the more appropriate cache_debug_on().

Urgh. Sounds Slabby. Cache is too generic. kmem_cache_debug_on()?

I thought the generic is ok here since its only use is within slub.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
