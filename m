Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4806B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 18:18:05 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so12172210pdb.38
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 15:18:05 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id l8si7297522pao.297.2014.02.14.15.18.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 15:18:03 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so12970871pab.38
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 15:18:03 -0800 (PST)
Date: Fri, 14 Feb 2014 15:18:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/9] slab: makes clear_obj_pfmemalloc() just return store
 masked value
In-Reply-To: <alpine.DEB.2.10.1402141225460.12887@nuc>
Message-ID: <alpine.DEB.2.02.1402141516540.13935@chino.kir.corp.google.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-3-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.10.1402141225460.12887@nuc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Christoph Lameter wrote:

> > @@ -215,9 +215,9 @@ static inline void set_obj_pfmemalloc(void **objp)
> >  	return;
> >  }
> >
> > -static inline void clear_obj_pfmemalloc(void **objp)
> > +static inline void *clear_obj_pfmemalloc(void *objp)
> >  {
> > -	*objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
> > +	return (void *)((unsigned long)objp & ~SLAB_OBJ_PFMEMALLOC);
> >  }
> 
> I dont think you need the (void *) cast here.
> 

Yeah, you don't need it, but don't you think it makes the code more 
readable?  Otherwise this is going to be just doing

	return (unsigned long)objp & ~SLAB_OBJ_PFMEMALLOC;

and you gotta figure out the function type to understand it's returned as 
a pointer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
