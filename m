Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCD86B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 16:40:53 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so3439768lbv.21
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 13:40:53 -0700 (PDT)
Received: from smtp1.it.da.ut.ee (mailhost6-1.ut.ee. [2001:bb8:2002:500::46])
        by mx.google.com with ESMTP id aq3si36445277lbc.78.2014.10.16.13.40.50
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 13:40:50 -0700 (PDT)
Date: Thu, 16 Oct 2014 23:40:49 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <alpine.LRH.2.11.1410162319080.19924@adalberg.ut.ee>
Message-ID: <alpine.LRH.2.11.1410162339220.19924@adalberg.ut.ee>
References: <alpine.LRH.2.11.1410150012001.11850@adalberg.ut.ee> <20141014.173246.921084057467310731.davem@davemloft.net> <alpine.LRH.2.11.1410160956090.13273@adalberg.ut.ee> <20141016.160742.1639247937393238792.davem@redhat.com>
 <alpine.LRH.2.11.1410162319080.19924@adalberg.ut.ee>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@redhat.com>
Cc: iamjoonsoo.kim@lge.com, Linux Kernel list <linux-kernel@vger.kernel.org>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> > I just reproduced this on my Sun Blade 2500, so it can trigger on UltraSPARC-IIIi
> > systems too.
> 
> I looked it up - V210 and V440 are also IIIi, not plain III. So I do not 
> have information about real USIII, sorry for confusion.

Brr, I just understood I confused 2 problems with the same subject. You 
are talking about SIGBUS problem that is also happening on IIIi, my last 
comment is about gcc-4.9 problem so please just ignore it.

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
