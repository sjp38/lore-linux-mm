Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0BB356B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 09:55:24 -0400 (EDT)
Date: Mon, 24 May 2010 08:52:02 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2] slub: move kmem_cache_node into it's own cacheline
In-Reply-To: <20100521214135.23902.55360.stgit@gitlad.jf.intel.com>
Message-ID: <alpine.DEB.2.00.1005240851480.5045@router.home>
References: <20100521214135.23902.55360.stgit@gitlad.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: penberg@cs.helsinki.fi, cl@linux.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
