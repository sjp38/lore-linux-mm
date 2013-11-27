Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1A10A6B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 16:39:31 -0500 (EST)
Received: by mail-ve0-f171.google.com with SMTP id pa12so5701287veb.30
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 13:39:30 -0800 (PST)
Received: from mail-yh0-x22b.google.com (mail-yh0-x22b.google.com [2607:f8b0:4002:c01::22b])
        by mx.google.com with ESMTPS id sl9si6839462vdc.138.2013.11.27.13.39.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 13:39:30 -0800 (PST)
Received: by mail-yh0-f43.google.com with SMTP id a41so4992983yho.30
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 13:39:02 -0800 (PST)
Date: Wed, 27 Nov 2013 13:38:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
In-Reply-To: <20131127163916.GB3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311271336220.9222@chino.kir.corp.google.com>
References: <1385140676-5677-1-git-send-email-hannes@cmpxchg.org> <alpine.DEB.2.02.1311261658170.21003@chino.kir.corp.google.com> <alpine.DEB.2.02.1311261931210.5973@chino.kir.corp.google.com> <20131127163916.GB3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 27 Nov 2013, Johannes Weiner wrote:

> > Ah, this is because of 3168ecbe1c04 ("mm: memcg: use proper memcg in limit 
> > bypass") which just bypasses all of these allocations and charges the root 
> > memcg.  So if allocations want to bypass memcg isolation they just have to 
> > be __GFP_NOFAIL?
> 
> I don't think we have another option.
> 

We don't give __GFP_NOFAIL allocations access to memory reserves in the 
page allocator and we do call the oom killer for them so that a process is 
killed so that memory is freed.  Why do we have a different policy for 
memcg?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
