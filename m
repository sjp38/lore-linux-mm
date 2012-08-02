Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 243136B006E
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:48:00 -0400 (EDT)
Received: by yenr5 with SMTP id r5so10954702yen.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 13:47:59 -0700 (PDT)
Date: Thu, 2 Aug 2012 13:47:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Common [01/19] slub: Add debugging to verify correct cache use
 on kmem_cache_free()
In-Reply-To: <alpine.DEB.2.00.1208021540590.32229@router.home>
Message-ID: <alpine.DEB.2.00.1208021346130.5454@chino.kir.corp.google.com>
References: <20120802201506.266817615@linux.com> <20120802201530.921218259@linux.com> <alpine.DEB.2.00.1208021334350.5454@chino.kir.corp.google.com> <alpine.DEB.2.00.1208021540590.32229@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Christoph Lameter wrote:

> This condition is pretty serious. The free action will be skipped
> and we will be continually leaking memory. I think its best to keep on
> logging this until someohne does something about the problem.
> 

Dozens of lines will be emitted to the kernel log because a stack trace is 
printed every time a bogus kmem_cache_free() is called, perhaps change the 
WARN_ON(1) to at least a WARN_ON_ONCE(1)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
