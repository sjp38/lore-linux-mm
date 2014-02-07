Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 769B76B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 21:46:32 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so2545801pde.7
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 18:46:32 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id va10si3119162pbc.278.2014.02.06.18.46.30
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 18:46:30 -0800 (PST)
Date: Fri, 7 Feb 2014 10:46:02 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [slub] WARNING: CPU: 1 PID: 1 at mm/slub.c:992 deactivate_slab()
Message-ID: <20140207024602.GA12062@localhost>
References: <20140205072558.GC9379@localhost>
 <alpine.DEB.2.02.1402050009200.7839@chino.kir.corp.google.com>
 <20140205112449.GB18849@localhost>
 <alpine.DEB.2.02.1402051123520.5616@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1402061340360.12761@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402061340360.12761@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 06, 2014 at 01:41:10PM -0800, David Rientjes wrote:
> On Wed, 5 Feb 2014, David Rientjes wrote:
> 
> > Ah, that's because the patch didn't go through Pekka's slab tree but went 
> > into -mm instead so we have to wait for another -mm.  However, the traces 
> > from linux-next-20140204 that you provided indicate it's the same problem 
> > and should be fixed with that patch, so let's wait for another mmotm to be 
> > released.
> > 
> 
> Ok, "mm/slub.c: list_lock may not be held in some circumstances" is in 
> linux-next so let me know if this reproduces!

Yeah, linux-next 20140206 no longer has this WARNING!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
