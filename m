Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 99F606B01AF
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 12:17:58 -0400 (EDT)
Date: Wed, 9 Jun 2010 11:14:37 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC V2 SLEB 06/14] SLUB: Get rid of the kmalloc_node slab
In-Reply-To: <alpine.DEB.2.00.1006082311130.28827@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006091112120.21686@router.home>
References: <20100521211452.659982351@quilx.com> <20100521211540.439539135@quilx.com> <alpine.DEB.2.00.1006082311130.28827@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


The patch needs a rework since it sometimes calculates the wrong kmalloc
slab. Value needs to be rounded up to the next kmalloc slab size. This
problem shows up if CONFIG_SLUB_DEBUG is enabled.

Please do not merge patches that are marked "RFC". That usually means
that I am not satisfied with their quality yet.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
