Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9808F6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 19:59:24 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id t15so72670901igr.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:59:24 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id iq7si9065981igb.92.2016.01.26.16.59.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 16:59:23 -0800 (PST)
Date: Wed, 27 Jan 2016 09:59:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH/RFC 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
Message-ID: <20160127005920.GB7089@js1304-P5Q-DELUXE>
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
 <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com>
 <20160126181903.GB4671@osiris>
 <alpine.DEB.2.10.1601261525580.25141@chino.kir.corp.google.com>
 <20160127001918.GA7089@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1601261633520.6121@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601261633520.6121@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On Tue, Jan 26, 2016 at 04:36:11PM -0800, David Rientjes wrote:
> On Wed, 27 Jan 2016, Joonsoo Kim wrote:
> 
> > > I'd agree if CONFIG_DEBUG_PAGEALLOC only did anything when 
> > > debug_pagealloc_enabled() is true, but that doesn't seem to be the case.  
> > > When CONFIG_DEBUG_SLAB is enabled, for instance, CONFIG_DEBUG_PAGEALLOC 
> > > also enables stackinfo storing and poisoning and it's not guarded by 
> > > debug_pagealloc_enabled().
> > > 
> > > It seems like CONFIG_DEBUG_PAGEALLOC enables debugging functionality 
> > > outside the scope of the debug_pagealloc=on kernel parameter, so 
> > > DEBUG_PAGEALLOC(disabled) actually does mean something.
> > 
> > Hello, David.
> > 
> > I tried to fix CONFIG_DEBUG_SLAB case on 04/16 of following patchset.
> > 
> > http://thread.gmane.org/gmane.linux.kernel.mm/144527
> > 
> > I found that there are more sites to fix but not so many.
> > We can do it.
> > 
> 
> For the slab case, sure, this can be fixed, but there is other code that 
> uses CONFIG_DEBUG_PAGEALLOC to suggest debugging is always enabled and is 
> indifferent to debug_pagealloc_enabled().  I find this in powerpc and 
> sparc arch code as well as generic vmalloc code.  

Yes, I also found it.

> 
> If we can convert existing users that only check for 
> CONFIG_DEBUG_PAGEALLOC to rather check for debug_pagealloc_enabled() and 
> agree that it is only enabled for debug_pagealloc=on, then this would seem 
> fine.  However, I think we should at least consult with those users before 
> removing an artifact from the kernel log that could be useful in debugging 
> why a particular BUG() happened.

Yes, at least, non-architecture dependent code (vmalloc, SLAB, SLUB) should
be changed first. If Christian doesn't mind, I will try to fix above 3
things.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
