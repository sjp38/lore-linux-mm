Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id D96F56B009B
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:42:12 -0400 (EDT)
Date: Thu, 2 Aug 2012 15:42:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [01/19] slub: Add debugging to verify correct cache use
 on kmem_cache_free()
In-Reply-To: <alpine.DEB.2.00.1208021334350.5454@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1208021540590.32229@router.home>
References: <20120802201506.266817615@linux.com> <20120802201530.921218259@linux.com> <alpine.DEB.2.00.1208021334350.5454@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, David Rientjes wrote:

> This could quickly spam the kernel log depending on how frequently objects
> are being freed from the buggy callsite, should we disable further
> debugging for the cache in situations like this?

This condition is pretty serious. The free action will be skipped
and we will be continually leaking memory. I think its best to keep on
logging this until someohne does something about the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
