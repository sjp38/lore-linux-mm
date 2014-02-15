Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9519D6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 19:26:19 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id e9so20855346qcy.26
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 16:26:19 -0800 (PST)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id y3si5199903qas.76.2014.02.14.16.26.18
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 16:26:18 -0800 (PST)
Date: Fri, 14 Feb 2014 18:26:15 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/9] slab: makes clear_obj_pfmemalloc() just return store
 masked value
In-Reply-To: <alpine.DEB.2.02.1402141516540.13935@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1402141824300.5204@nuc>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-3-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.10.1402141225460.12887@nuc> <alpine.DEB.2.02.1402141516540.13935@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, David Rientjes wrote:

> Yeah, you don't need it, but don't you think it makes the code more
> readable?  Otherwise this is going to be just doing
>
> 	return (unsigned long)objp & ~SLAB_OBJ_PFMEMALLOC;
>
> and you gotta figure out the function type to understand it's returned as

Isnt there something like PTR_ALIGN() for this case that would make it
more readable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
