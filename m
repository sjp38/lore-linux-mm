Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 123CE6B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 01:14:55 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so14475846pdj.39
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 22:14:55 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id sd3si13602351pbb.222.2014.02.16.22.14.52
        for <linux-mm@kvack.org>;
        Sun, 16 Feb 2014 22:14:53 -0800 (PST)
Date: Mon, 17 Feb 2014 15:15:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/9] slab: makes clear_obj_pfmemalloc() just return store
 masked value
Message-ID: <20140217061502.GB3468@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1392361043-22420-3-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.10.1402141225460.12887@nuc>
 <alpine.DEB.2.02.1402141516540.13935@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1402141824300.5204@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402141824300.5204@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 14, 2014 at 06:26:15PM -0600, Christoph Lameter wrote:
> On Fri, 14 Feb 2014, David Rientjes wrote:
> 
> > Yeah, you don't need it, but don't you think it makes the code more
> > readable?  Otherwise this is going to be just doing
> >
> > 	return (unsigned long)objp & ~SLAB_OBJ_PFMEMALLOC;
> >
> > and you gotta figure out the function type to understand it's returned as
> 
> Isnt there something like PTR_ALIGN() for this case that would make it
> more readable?

I can't find what you want.
I agree with David's opinion and want to keep patch as is.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
