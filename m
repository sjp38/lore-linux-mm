Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6FD6B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:04:15 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so3622600pbc.8
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:04:15 -0800 (PST)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id yg10si1704152pbc.272.2014.01.30.14.04.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 14:04:14 -0800 (PST)
Received: by mail-pb0-f51.google.com with SMTP id un15so3634253pbc.24
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:04:14 -0800 (PST)
Date: Thu, 30 Jan 2014 14:04:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: fix mutex not unlocked on memcg_create_kmem_cache
 fail path
In-Reply-To: <20140130135002.22ce1c12b7136f75e5985df6@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1401301403090.15271@chino.kir.corp.google.com>
References: <1391097693-31401-1-git-send-email-vdavydov@parallels.com> <20140130130129.6f8bd7fd9da55d17a9338443@linux-foundation.org> <alpine.DEB.2.02.1401301310270.15271@chino.kir.corp.google.com> <20140130132939.96a25a37016a12f9a0093a90@linux-foundation.org>
 <alpine.DEB.2.02.1401301336530.15271@chino.kir.corp.google.com> <20140130135002.22ce1c12b7136f75e5985df6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 30 Jan 2014, Andrew Morton wrote:

> > Yeah, it shouldn't be temporary it should be the one and only allocation.  
> > We should construct the name in memcg_create_kmem_cache() and be done with 
> > it.
> 
> Could.  That would require converting memcg_create_kmem_cache() to take 
> a va_list and call kasprintf() on it.
> 

Why?  We already construct the name in memcg_create_kmem_cache() 
appropriately, we just want to avoid the kstrdup() in 
kmem_cache_create_memcg() since it's pointless like my patch does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
