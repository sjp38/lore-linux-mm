Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D981F6B038F
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 17:23:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c5so13112199wmi.0
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 14:23:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i199si12306353wmf.9.2017.03.19.14.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 14:23:51 -0700 (PDT)
Date: Sun, 19 Mar 2017 17:23:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 0/8] try to reduce fragmenting fallbacks
Message-ID: <20170319212340.GA24053@cmpxchg.org>
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170308164631.GA12130@cmpxchg.org>
 <fbc47cf0-2f8f-defc-cd79-50395e9985a7@suse.cz>
 <20170316183422.GA1461@cmpxchg.org>
 <0e01d912-9473-35df-5bc7-f080ab9c1818@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0e01d912-9473-35df-5bc7-f080ab9c1818@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com

On Fri, Mar 17, 2017 at 07:29:54PM +0100, Vlastimil Babka wrote:
> On 03/16/2017 07:34 PM, Johannes Weiner wrote:
> > The patched kernel also consistently beats vanilla in terms of peak
> > job throughput.
> > 
> > Overall very cool!
> 
> Thanks a lot! So that means it's worth the increased compaction stats
> you reported earlier?

Yes, from the impact this patchset has on the workload overall, I'm
assuming that the increased work pays off.

So maybe something to keep an eye out for, but IMO not a dealbreaker.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
