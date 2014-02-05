Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id EE89F6B0037
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 14:25:38 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so764140pbb.21
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 11:25:38 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id sj5si30094971pab.342.2014.02.05.11.25.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 11:25:38 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so734946pab.16
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 11:25:37 -0800 (PST)
Date: Wed, 5 Feb 2014 11:25:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [slub] WARNING: CPU: 1 PID: 1 at mm/slub.c:992
 deactivate_slab()
In-Reply-To: <20140205112449.GB18849@localhost>
Message-ID: <alpine.DEB.2.02.1402051123520.5616@chino.kir.corp.google.com>
References: <20140205072558.GC9379@localhost> <alpine.DEB.2.02.1402050009200.7839@chino.kir.corp.google.com> <20140205112449.GB18849@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 5 Feb 2014, Fengguang Wu wrote:

> > I think this is the inlined add_full() and should be fixed with 
> > http://marc.info/?l=linux-kernel&m=139147105027693 that has been added to 
> > the -mm tree and should now be in next.  Is this patch included for this 
> > kernel?
> 
> Hi David,
> 
> According to the bisect log, linux-next 20140204 is bad, but it does
> not yet include your fix.
> 
> git bisect  bad 38dbfb59d1175ef458d006556061adeaa8751b72  # 23:16      0-      2  Linus 3.14-rc1
> git bisect  bad cdd263faccc2184e685573968dae5dd34758e322  # 23:34      1-      3  Add linux-next specific files for 20140204
> 

Ah, that's because the patch didn't go through Pekka's slab tree but went 
into -mm instead so we have to wait for another -mm.  However, the traces 
from linux-next-20140204 that you provided indicate it's the same problem 
and should be fixed with that patch, so let's wait for another mmotm to be 
released.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
