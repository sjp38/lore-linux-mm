Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 958B66B0044
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 14:27:34 -0400 (EDT)
Date: Thu, 2 Aug 2012 13:27:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
In-Reply-To: <alpine.DEB.2.00.1208021313040.27953@router.home>
Message-ID: <alpine.DEB.2.00.1208021326390.27953@router.home>
References: <20120801211130.025389154@linux.com> <501A3F1E.4060307@parallels.com> <alpine.DEB.2.00.1208020912340.23049@router.home> <501A8BE4.4060206@parallels.com> <alpine.DEB.2.00.1208020941150.23049@router.home> <501A92FB.8020906@parallels.com>
 <alpine.DEB.2.00.1208021305200.27953@router.home> <501AC247.8020306@parallels.com> <alpine.DEB.2.00.1208021313040.27953@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Christoph Lameter wrote:

> The patch that reduces the parameters to __kmem_cache_create.

If you add a

	s->refcount = 1;

before the

	return s;

in create_kmalloc_cache() then all will be well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
