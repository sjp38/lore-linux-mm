Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 543F76B01AF
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 12:22:05 -0400 (EDT)
Date: Wed, 9 Jun 2010 11:18:24 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 1/4] slub: replace SLAB_NODE_UNSPECIFIED with
 NUMA_NO_NODE
In-Reply-To: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006091114580.21686@router.home>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Sigh. I wish we could have avoided this. Neither name is satisfactory
here. The meaning of -1 is unspecified. A node specification may be
implicit here depending on the memory allocation policy. I was not sure
how exactly to resolve the situation.

But this way work with NUMA_NO_NODE. Certainly better.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
