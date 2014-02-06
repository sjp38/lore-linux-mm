Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8776B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:38:37 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so2446702pbb.3
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:38:37 -0800 (PST)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id tq3si2438455pab.241.2014.02.06.13.41.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 13:41:42 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id x10so2237432pdj.25
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 13:41:11 -0800 (PST)
Date: Thu, 6 Feb 2014 13:41:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [slub] WARNING: CPU: 1 PID: 1 at mm/slub.c:992
 deactivate_slab()
In-Reply-To: <alpine.DEB.2.02.1402051123520.5616@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1402061340360.12761@chino.kir.corp.google.com>
References: <20140205072558.GC9379@localhost> <alpine.DEB.2.02.1402050009200.7839@chino.kir.corp.google.com> <20140205112449.GB18849@localhost> <alpine.DEB.2.02.1402051123520.5616@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 5 Feb 2014, David Rientjes wrote:

> Ah, that's because the patch didn't go through Pekka's slab tree but went 
> into -mm instead so we have to wait for another -mm.  However, the traces 
> from linux-next-20140204 that you provided indicate it's the same problem 
> and should be fixed with that patch, so let's wait for another mmotm to be 
> released.
> 

Ok, "mm/slub.c: list_lock may not be held in some circumstances" is in 
linux-next so let me know if this reproduces!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
