Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 321E36B0275
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 12:39:31 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id bk3so98415267wjc.4
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 09:39:31 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id h194si14203012wmd.115.2016.12.08.09.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 09:39:30 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id B64BC1C1FF3
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 17:39:28 +0000 (GMT)
Date: Thu, 8 Dec 2016 17:39:28 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161208173928.gts7vsu6rqj4dicx@techsingularity.net>
References: <1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207211958.s3ymjva54wgakpkm@techsingularity.net>
 <20161207232531.fxqdgrweilej5gs6@techsingularity.net>
 <20161208092231.55c7eacf@redhat.com>
 <20161208091806.gzcxlerxprcjvt3l@techsingularity.net>
 <20161208114308.1c6a424f@redhat.com>
 <20161208110656.bnkvqg73qnjkehbc@techsingularity.net>
 <20161208154813.5dafae7b@redhat.com>
 <20161208151101.pigfrnqd5i4n45uv@techsingularity.net>
 <20161208181951.6c06e559@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161208181951.6c06e559@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Dec 08, 2016 at 06:19:51PM +0100, Jesper Dangaard Brouer wrote:
> > > See patch below signature.
> > > 
> > > Besides I think you misunderstood me, you can adjust:
> > >  sysctl net.core.rmem_max
> > >  sysctl net.core.wmem_max
> > > 
> > > And you should if you plan to use/set 851968 as socket size for UDP
> > > remote tests, else you will be limited to the "max" values (212992 well
> > > actually 425984 2x default value, for reasons I cannot remember)
> > >   
> > 
> > The intent is to use the larger values to avoid packet loss on
> > UDP_STREAM.
> 
> We do seem to misunderstand each-other.
> I was just pointing out two things:
> 
> 1. Notice the difference between "max" and "default" proc setting.
>    Only adjust the "max" setting.
> 
> 2. There was simple BASH-shell script error in your commit.
>    Patch below fix it.
> 

Understood now.

> [PATCH] mmtests: actually use variable SOCKETSIZE_OPT
> 
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> 

Applied, thanks!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
