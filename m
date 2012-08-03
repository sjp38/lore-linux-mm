Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 507936B005D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:37:53 -0400 (EDT)
Date: Fri, 3 Aug 2012 09:07:27 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [02/19] slub: Use kmem_cache for the kmem_cache
 structure
In-Reply-To: <alpine.DEB.2.00.1208021352000.5454@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1208030904560.2332@router.home>
References: <20120802201506.266817615@linux.com> <20120802201531.490489455@linux.com> <alpine.DEB.2.00.1208021352000.5454@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, David Rientjes wrote:

> Nice catch of the memory leak!

No memory leak. kmem_cache was alrady released on kmem_cache_release() via
sysfs. This introduced the double free that Glauber saw.

Fixing this issue causes subsequent patches to also need some changes.
Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
