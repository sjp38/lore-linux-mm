Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 84E046B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:13:21 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id q10so3564314pdj.38
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:13:21 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id ez5si8042355pab.77.2014.01.30.14.13.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 14:13:20 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so3659185pbb.34
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:13:20 -0800 (PST)
Date: Thu, 30 Jan 2014 14:13:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: fix mutex not unlocked on memcg_create_kmem_cache
 fail path
In-Reply-To: <20140130140902.93d35d866f9ea1c697811f6e@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1401301411590.15271@chino.kir.corp.google.com>
References: <1391097693-31401-1-git-send-email-vdavydov@parallels.com> <20140130130129.6f8bd7fd9da55d17a9338443@linux-foundation.org> <alpine.DEB.2.02.1401301310270.15271@chino.kir.corp.google.com> <20140130132939.96a25a37016a12f9a0093a90@linux-foundation.org>
 <alpine.DEB.2.02.1401301336530.15271@chino.kir.corp.google.com> <20140130135002.22ce1c12b7136f75e5985df6@linux-foundation.org> <alpine.DEB.2.02.1401301403090.15271@chino.kir.corp.google.com> <20140130140902.93d35d866f9ea1c697811f6e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 30 Jan 2014, Andrew Morton wrote:

> > Why?  We already construct the name in memcg_create_kmem_cache() 
> > appropriately, we just want to avoid the kstrdup() in 
> > kmem_cache_create_memcg() since it's pointless like my patch does.
> 
> oh, OK, missed that.
> 
> The problem now is that the string at kmem_cache.name is PATH_MAX
> bytes, and PATH_MAX is huuuuuuuge.
> 

It always was.  Google uses pretty long memcg names (although admittedly 
not as long as PATH_MAX!) and it hasn't caused any problem with 
/proc/slabinfo or slabtop(1).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
