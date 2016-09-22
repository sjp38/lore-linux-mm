Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D01D280250
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:37:59 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b71so54288588lfg.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 05:37:59 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id te1si1687107wjb.41.2016.09.22.05.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 05:37:38 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w84so13846642wmg.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 05:37:38 -0700 (PDT)
Date: Thu, 22 Sep 2016 14:37:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/5] mm/vmalloc.c: correct lazy_max_pages() return value
Message-ID: <20160922123736.GA11204@dhcp22.suse.cz>
References: <57E20C49.8010304@zoho.com>
 <alpine.DEB.2.10.1609211418480.20971@chino.kir.corp.google.com>
 <3ef46c24-769d-701a-938b-826f4249bf0b@zoho.com>
 <alpine.DEB.2.10.1609211731230.130215@chino.kir.corp.google.com>
 <57E3304E.4060401@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E3304E.4060401@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Thu 22-09-16 09:13:50, zijun_hu wrote:
> On 09/22/2016 08:35 AM, David Rientjes wrote:
[...]
> > The intent is as it is implemented; with your change, lazy_max_pages() is 
> > potentially increased depending on the number of online cpus.  This is 
> > only a heuristic, changing it would need justification on why the new 
> > value is better.  It is opposite to what the comment says: "to be 
> > conservative and not introduce a big latency on huge systems, so go with
> > a less aggressive log scale."  NACK to the patch.
> > 
> my change potentially make lazy_max_pages() decreased not increased, i seems
> conform with the comment
> 
> if the number of online CPUs is not power of 2, both have no any difference
> otherwise, my change remain power of 2 value, and the original code rounds up
> to next power of 2 value, for instance
> 
> my change : (32, 64] -> 64
> 	     32 -> 32, 64 -> 64
> the original code: [32, 63) -> 64
>                    32 -> 64, 64 -> 128

You still completely failed to explain _why_ this is an improvement/fix
or why it matters. This all should be in the changelog.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
