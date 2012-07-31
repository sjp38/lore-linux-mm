Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp103.postini.com [74.125.245.223])
	by kanga.kvack.org (Postfix) with SMTP id D31376B0081
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:26:00 -0400 (EDT)
Date: Tue, 31 Jul 2012 11:30:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [13/20] Extract a common function for
 kmem_cache_destroy
In-Reply-To: <5017EFE9.1080804@parallels.com>
Message-ID: <alpine.DEB.2.00.1207311129520.32295@router.home>
References: <20120601195245.084749371@linux.com> <20120601195307.063633659@linux.com> <5017C90E.7060706@parallels.com> <alpine.DEB.2.00.1207310910580.32295@router.home> <5017E8C3.1040004@parallels.com> <alpine.DEB.2.00.1207310942090.32295@router.home>
 <5017EFE9.1080804@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Tue, 31 Jul 2012, Glauber Costa wrote:

> Yes, but since deleting caches is not a common operation in the kernel,
> you will have to force somehow.

On bootup the ACPI subsystem creates some caches and also removes them.
This bug actually triggers here even when using kvm. Seems that this is
due to some use of kmalloc allocations for kmem_cache in slub where we use
kmalloc-256 instead of kmem_cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
