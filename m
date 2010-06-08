Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B59126B01B4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:36:00 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o58NZtZR006114
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 16:35:55 -0700
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by kpbe16.cbf.corp.google.com with ESMTP id o58NZsIF014113
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 16:35:54 -0700
Received: by pzk27 with SMTP id 27so161133pzk.2
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 16:35:54 -0700 (PDT)
Date: Tue, 8 Jun 2010 16:35:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 01/14] slab: Introduce a constant for a unspecified
 node.
In-Reply-To: <AANLkTikQhjlCPnwiK7AZo27Xb3h-Lj2JyCeqFQaVzpHX@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006081633450.19582@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100521211537.530913777@quilx.com> <alpine.DEB.2.00.1006071443120.10905@chino.kir.corp.google.com> <alpine.DEB.2.00.1006071729560.12482@router.home> <AANLkTikOKy6ZQQh2zORJDvGDE0golvyzsvlvDj-P5cur@mail.gmail.com>
 <alpine.DEB.2.00.1006072319330.31780@chino.kir.corp.google.com> <AANLkTikQhjlCPnwiK7AZo27Xb3h-Lj2JyCeqFQaVzpHX@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Pekka Enberg wrote:

> > An incremental patch in this case would change everything that the
> > original patch did, so it'd probably be best to simply revert and queue
> > the updated version.
> 
> If I revert it, we end up with two commits instead of one. And I
> really prefer not to *rebase* a topic branch even though it might be
> doable for a small tree like slab.git.
> 

I commented on improvements for three of the five patches you've added as 
slub cleanups and Christoph has shown an interest in proposing them again 
(perhaps seperating patches 1-5 out as a seperate set of cleanups?), so 
it's probably cleaner to just reset and reapply with the revisions.  

Let me know if my suggested changes should be add-on patches to 
Christoph's first five and I'll come up with a three patch series to do 
just that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
