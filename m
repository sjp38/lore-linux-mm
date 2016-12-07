Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39E536B0069
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 18:25:34 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so89511413wjb.7
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 15:25:34 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id t10si10592761wmb.0.2016.12.07.15.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 15:25:32 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 7DF201C1D70
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 23:25:32 +0000 (GMT)
Date: Wed, 7 Dec 2016 23:25:31 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161207232531.fxqdgrweilej5gs6@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
 <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207194801.krhonj7yggbedpba@techsingularity.net>
 <1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207211958.s3ymjva54wgakpkm@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161207211958.s3ymjva54wgakpkm@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Dec 07, 2016 at 09:19:58PM +0000, Mel Gorman wrote:
> At small packet sizes on localhost, I see relatively low page allocator
> activity except during the socket setup and other unrelated activity
> (khugepaged, irqbalance, some btrfs stuff) which is curious as it's
> less clear why the performance was improved in that case. I considered
> the possibility that it was cache hotness of pages but that's not a
> good fit. If it was true then the first test would be slow and the rest
> relatively fast and I'm not seeing that. The other side-effect is that
> all the high-order pages that are allocated at the start are physically
> close together but that shouldn't have that big an impact. So for now,
> the gain is unexplained even though it happens consistently.
> 

Further investigation led me to conclude that the netperf automation on
my side had some methodology errors that could account for an artifically
low score in some cases. The netperf automation is years old and would
have been developed against a much older and smaller machine which may be
why I missed it until I went back looking at exactly what the automation
was doing. Minimally in a server/client test on remote maching there was
potentially higher packet loss than is acceptable. This would account why
some machines "benefitted" while others did not -- there would be boot to
boot variations that some machines happened to be "lucky". I believe I've
corrected the errors, discarded all the old data and scheduled a rest to
see what falls out.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
