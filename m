Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37221C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:43:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDD1222BEF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:43:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDD1222BEF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 748566B0003; Thu, 25 Jul 2019 18:43:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F8C36B0005; Thu, 25 Jul 2019 18:43:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E7E48E0002; Thu, 25 Jul 2019 18:43:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 109B76B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 18:43:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so32966091eda.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 15:43:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Pby7w/PiSuZvSR/2ysajIXqI+pRhohNna5mcrcQGWnI=;
        b=cieIW3TyBJ4rFgJooy31lc40kf3t90Yd/75jXOI6F6Q2AGXkMoRoA43q/IIrm1Q/nR
         nwVFJ4pHE9+2PRV5zZFd/evtWwIkIyiBaqjAB/Z5bB7jC6UMomR8voYhJANa1U4fa7O/
         xYiVcl6rf3ehXqzjZo+lylm3WpNH8BMrLHOUn3GyTfQ7mfPxtyleQXrDXHbFsk6mQDiA
         R/+SAIcxakWxLTbg8JVTLypmJLkpOFhXUs8P04zAmuuERpoS4wq6SKnBgBFRn7MaLd0l
         TFKlzgGCCh6ljdYJt2jGhyhbJU3KdPlWd6LwS9t/TKdkzg4BUa+Y2vwRyYRL+at7mwtz
         ZlgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAWqDFwwcu4v/ChJEsMDren4rEYmU5Vq8baZbJkuPch9CRmYMsK2
	UUSa0DhcOGh5ImoDM7E3PKLGKCRE8sODlRbCaGI/NdsZdXYQzVtxmUQiqNtgxTYyjyB4rVlfNoC
	TCT0xaWKCWQf0yzPzsPe7d9wHivf8vp03rpkAgZz6KuoiSxAQVZaEkBW2vvG+3xoMxA==
X-Received: by 2002:a50:d8cf:: with SMTP id y15mr78956285edj.213.1564094594493;
        Thu, 25 Jul 2019 15:43:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9Tlzwav51POFrgLmxfJJmmeEk3bQBq2SPQo8dDNlMBwv48L/RCqzTpA0qNIFApRYmbV6O
X-Received: by 2002:a50:d8cf:: with SMTP id y15mr78956242edj.213.1564094593545;
        Thu, 25 Jul 2019 15:43:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564094593; cv=none;
        d=google.com; s=arc-20160816;
        b=HEqp5RQfApBy48N496+h9anjkLDBR/54KhqpMU+KPIg2eNHwSc31r3O288w7DNXMdh
         urkXyLGbDO6rffpX0L5dCG+aQ/cXXhWMlL/GlsiG6IbKv8gJOk3DkhM3JDvsXo5Ppkl7
         Z6L0Jpgi6VhF0xu2rGChzBWsWYIpFJOCdhy7ftSworRGrdAHJBm5bQSeY/1FN7BI//uN
         qpiStGK+GaZO4kegJEUXrKTgPnKz5Pac7ClQE0wi7oVTCxwrrCoKTyqcxXF5qfqaSl6X
         RCHD490eGACysJXoJlFiBL4X5l07VrW46SO3pVTaWECPr2ekd3vvKRVCSzj/hVuGLV+X
         dwjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Pby7w/PiSuZvSR/2ysajIXqI+pRhohNna5mcrcQGWnI=;
        b=h/FPR3v5kZad2vy3xXSFAjh3Qzmsk+CfELjIYIN+ViyvHaCN71yCuPYw/9hCFhNeHB
         jIzOLiRHggEz3Wur1kToMFLcMAwaDoDx/9FB5BavRAZeSR1qmkaLQEqFW6Axkr3h7KV+
         vbdaKPkZlapuJvOw2hKpwVFXclKGweFvMPm62B2oWGtQtBodZuiJq9236lRHSkN9rprY
         PdUl5CQVRF6lb3b/9S16PMokwEY4mZzVLK9OdgsCVHwV/imE+oXMPWOvmiZj3Vhd4Pa6
         yFKotYSsGcVR2HLKZlGj9JkOmPu6iIGhYnJYISIixF5Ew3uaAKbta5Zodhy3ix9OL6Vs
         VmPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m54si11853050edd.429.2019.07.25.15.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 15:43:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DEB95AEF6;
	Thu, 25 Jul 2019 22:43:12 +0000 (UTC)
Date: Thu, 25 Jul 2019 23:43:07 +0100
From: Mel Gorman <mgorman@suse.de>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 3/3] hugetlbfs: don't retry when pool page
 allocations start to fail
Message-ID: <20190725224307.GE2708@suse.de>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-4-mike.kravetz@oracle.com>
 <20190725081350.GD2708@suse.de>
 <6a7f3705-9550-e22f-efa1-5e3616351df6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <6a7f3705-9550-e22f-efa1-5e3616351df6@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 10:15:29AM -0700, Mike Kravetz wrote:
> On 7/25/19 1:13 AM, Mel Gorman wrote:
> > On Wed, Jul 24, 2019 at 10:50:14AM -0700, Mike Kravetz wrote:
> >> When allocating hugetlbfs pool pages via /proc/sys/vm/nr_hugepages,
> >> the pages will be interleaved between all nodes of the system.  If
> >> nodes are not equal, it is quite possible for one node to fill up
> >> before the others.  When this happens, the code still attempts to
> >> allocate pages from the full node.  This results in calls to direct
> >> reclaim and compaction which slow things down considerably.
> >>
> >> When allocating pool pages, note the state of the previous allocation
> >> for each node.  If previous allocation failed, do not use the
> >> aggressive retry algorithm on successive attempts.  The allocation
> >> will still succeed if there is memory available, but it will not try
> >> as hard to free up memory.
> >>
> >> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> > 
> > set_max_huge_pages can fail the NODEMASK_ALLOC() alloc which you handle
> > *but* in the event of an allocation failure this bug can silently recur.
> > An informational message might be justified in that case in case the
> > stall should recur with no hint as to why.
> 
> Right.
> Perhaps a NODEMASK_ALLOC() failure should just result in a quick exit/error.
> If we can't allocate a node mask, it is unlikely we will be able to allocate
> a/any huge pages.  And, the system must be extremely low on memory and there
> are likely other bigger issues.
> 

That might be better overall, you make a valid point that a failed
kmalloc is not a good sign for hugetlbfs allocations.

> There have been discussions elsewhere about discontinuing the use of
> NODEMASK_ALLOC() and just putting the mask on the stack.  That may be
> acceptable here as well.
> 

They can be big and while this particular path would be relatively safe,
I think the fact that there will not be much functional difference
between allocating on the stack and a failed kmalloc in terms of
hugetlbfs allocation success rates.

> >                                            Technically passing NULL into
> > NODEMASK_FREE is also safe as kfree (if used for that kernel config) can
> > handle freeing of a NULL pointer. However, that is cosmetic more than
> > anything. Whether you decide to change either or not;
> 
> Yes.
> I will clean up with an updated series after more feedback.
> 

Thanks.

-- 
Mel Gorman
SUSE Labs

