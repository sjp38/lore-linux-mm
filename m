Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 07F8C6B0365
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 19:53:23 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o7KNrJMB002818
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 16:53:20 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by kpbe17.cbf.corp.google.com with ESMTP id o7KNrGZh010399
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 16:53:18 -0700
Received: by pwi3 with SMTP id 3so2106314pwi.28
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 16:53:16 -0700 (PDT)
Date: Fri, 20 Aug 2010 16:53:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup4 0/6] SLUB: Cleanups V4
In-Reply-To: <alpine.DEB.2.00.1008201810450.8436@router.home>
Message-ID: <alpine.DEB.2.00.1008201652480.16947@chino.kir.corp.google.com>
References: <20100820173711.136529149@linux.com> <alpine.DEB.2.00.1008201405080.4202@chino.kir.corp.google.com> <alpine.DEB.2.00.1008201810450.8436@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010, Christoph Lameter wrote:

> > > Remove static allocation of kmem_cache_cpu array and rely on the
> > > percpu allocator to allocate memory for the array on bootup.
> > >
> >
> > I don't see this patch in the v4 posting of your series.
> 
> I see it on the list. So I guess just wait until it reaches you.
> 

Ah, it finally hit me and marc.info, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
