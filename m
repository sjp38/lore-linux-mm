Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27BB46B026D
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:41:40 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 19so3404792ios.12
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 07:41:40 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id o76si5293792ita.12.2018.02.16.07.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 07:41:39 -0800 (PST)
Date: Fri, 16 Feb 2018 09:41:36 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
In-Reply-To: <20180215201405.GA22948@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802160940370.9660@nuc-kabylake>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com> <20180214095911.GB28460@dhcp22.suse.cz> <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com> <20180215144525.GG7275@dhcp22.suse.cz> <20180215151129.GB12360@bombadil.infradead.org>
 <alpine.DEB.2.20.1802150947240.1902@nuc-kabylake> <20180215201405.GA22948@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Thu, 15 Feb 2018, Matthew Wilcox wrote:

> On Thu, Feb 15, 2018 at 09:49:00AM -0600, Christopher Lameter wrote:
> > On Thu, 15 Feb 2018, Matthew Wilcox wrote:
> >
> > > What if ... on startup, slab allocated a MAX_ORDER page for itself.
> > > It would then satisfy its own page allocation requests from this giant
> > > page.  If we start to run low on memory in the rest of the system, slab
> > > can be induced to return some of it via its shrinker.  If slab runs low
> > > on memory, it tries to allocate another MAX_ORDER page for itself.
> >
> > The inducing of releasing memory back is not there but you can run SLUB
> > with MAX_ORDER allocations by passing "slab_min_order=9" or so on bootup.
>
> Maybe we should try this patch in order to automatically scale the slub
> page size with the amount of memory in the machine?

Well setting slub_min_order may cause allocation failures. You would leave
that at 0 for a prod configuration. Setting slub_max_order higher would
work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
