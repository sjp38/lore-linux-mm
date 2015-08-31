Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3839A6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 09:49:06 -0400 (EDT)
Received: by wicjd9 with SMTP id jd9so860604wic.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 06:49:05 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id s3si21092490wis.64.2015.08.31.06.49.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 06:49:04 -0700 (PDT)
Date: Mon, 31 Aug 2015 15:48:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH kernel vfio] mm: vfio: Move pages out of CMA before
 pinning
Message-ID: <20150831134854.GN19282@twins.programming.kicks-ass.net>
References: <1438762094-17747-1-git-send-email-aik@ozlabs.ru>
 <55D1910C.7070006@suse.cz>
 <55D1A525.5090706@ozlabs.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55D1A525.5090706@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Alexander Duyck <alexander.h.duyck@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Gibson <david@gibson.dropbear.id.au>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Paolo Bonzini <pbonzini@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>

On Mon, Aug 17, 2015 at 07:11:01PM +1000, Alexey Kardashevskiy wrote:
> >OK such conversation should probably start by mentioning the VM_PINNED
> >effort by Peter Zijlstra: https://lkml.org/lkml/2014/5/26/345
> >
> >It's more general approach to dealing with pinned pages, and moving them
> >out of CMA area (and compacting them in general) prior pinning is one of
> >the things that should be done within that framework.
> 
> 
> And I assume these patches did not go anywhere, right?...

I got lost in the IB code :/

Its on the TODO pile somewhere

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
