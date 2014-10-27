Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB626B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 03:53:13 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id eu11so4957983pac.37
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 00:53:12 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id r2si1790368pdh.33.2014.10.27.00.53.11
        for <linux-mm@kvack.org>;
        Mon, 27 Oct 2014 00:53:12 -0700 (PDT)
Date: Mon, 27 Oct 2014 16:54:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 0/4] [RFC] slub: Fastpath optimization (especially for RT)
Message-ID: <20141027075426.GE23379@js1304-P5Q-DELUXE>
References: <20141022155517.560385718@linux.com>
 <20141023080942.GA7598@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1410230916090.19494@gentwo.org>
 <20141024045630.GD15243@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1410240901020.26767@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1410240901020.26767@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Fri, Oct 24, 2014 at 09:02:18AM -0500, Christoph Lameter wrote:
> On Fri, 24 Oct 2014, Joonsoo Kim wrote:
> 
> > In this case, object from cpu1's cpu_cache should be
> > different with cpu0's, so allocation would be failed.
> 
> That is true for most object pointers unless the value is NULL. Which it
> can be. But if this is the only case then the second patch + your approach
> would work too.

Indeed... I missed the null value case.
Your second patch + mine would fix that situation, but, I need more
thinking. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
