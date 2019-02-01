Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF52CC4151A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97205218F0
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:17:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97205218F0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31B208E0002; Fri,  1 Feb 2019 09:17:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F03D8E0001; Fri,  1 Feb 2019 09:17:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BBA68E0002; Fri,  1 Feb 2019 09:17:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B4C7B8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 09:17:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id l45so2899174edb.1
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 06:17:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CCNleHAfR8vTpo+Edul3sweRpbLUDITX69CkpU264u4=;
        b=V37Lw62RG1uhXKO2jLPgwfQufujs9ukIEKQlBWLumGI/E5Y/jwuKtOkEsvVH+wIAkh
         rPkCf+RleyltaP8NMlGLDrWJZKol540ECvRuYDIuRrPzn+tfxTQhKpk11KSvQjGh0GmF
         w4PS9PHwt3ONd7oBsqk0kiDRAvoyYSTbVyuvuPZSiWSsdvG+0+yVyq1Ux8bbXOCuKvv/
         1TDgxsE3F86bVIInsS2+Zc2FhDHL3fL8JDAtFvwoAZ4K6fQZmpnmIYMYNEX7JTFVV/Ip
         rvf4MLDwPibl++bzVlr0vZNOCWIj3TIbU7PEnf5vje3sUoFf5w+mDuTlkrrYQbXHnPvB
         N/IA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: AJcUukfZ57DwcO08yn+y1mA9qwvmPxBVLqUbZsrTUQ389SyUFwWC7saP
	v/UkZTXGTlydb/RUS/Vm/+YTPa1gGE96plrXK7cCV8H4TeRP6jsiPIxrvgoyfFDjqnk1JkJhgcp
	+GA/uCmLLI2l5mCurRoGIFby+a0I1jCZH//zJuOYcPshFp42Ygot5DGkG4rXkXDggUA==
X-Received: by 2002:a17:906:1dd1:: with SMTP id v17-v6mr35331294ejh.148.1549030659186;
        Fri, 01 Feb 2019 06:17:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6uySWzz9cKqK+YReqqOgELHFTwlbPRV+n9axngOUvYy8ZYn2lSS/+mkn5Q7VP+g3H2HYLJ
X-Received: by 2002:a17:906:1dd1:: with SMTP id v17-v6mr35331212ejh.148.1549030657826;
        Fri, 01 Feb 2019 06:17:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549030657; cv=none;
        d=google.com; s=arc-20160816;
        b=WzP/6sHh4L7d1Mhm65uCUxAsLPc23geCU53lTSisGBJ+gC6eZoU1CivyDCneZkDLyJ
         nE9172CZ9dkLcQUyMd9slGZKPlxque1O/WlSdO4tWyue8q7dEoMyC79a+g/5+BHVtrR3
         RFC6k1ff0DihX3fbopFDdBFvP/cwmfoMr261rZ0a32x3VpAUnSX5JkKxLgSvxrWmgEuE
         /w48hoDhdujr7x83xgVLKr78AitZhv9L9pcwGBghSpHDbN04lhnZw4Iif9ivLPVPzsUt
         tAASTI38qaZQrstP2X8HKapmnVOikILX6s+CvZMMlNfVOWaSFZQL0e3fb6CVQTAwlbTY
         34Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CCNleHAfR8vTpo+Edul3sweRpbLUDITX69CkpU264u4=;
        b=d0z9QIz0IybuyGzDTUjcaVuKaOi3nGX4Jxy+6dI7Ff9Ey4bKBUwj9s6EYkD9pazxSu
         Sd4MWwcZHOrbyjbCWwhge5EqZGQ9KEBLCT/RKSXpJl4t4rZyC1LqurDVnR8aozDqHGNZ
         0hZMn7XMa8lynbYTpDp30Wq6B/Q7rWixzdXKevQGHwoIqi/crMf/fD9aYNPmHcTOm/g5
         1NTsWfpsk3FDqVYOKQivimseP8EORJW6tKyDDVf2BgiyMX6CT5LBbAeUpVYc7R3cWShl
         3/UcSGTMSQdIFW+7SzH7Q7I9vujK/QN8rk8BxQKiOQqwaxFUZ8Sa0fda3XnH2YidXqC8
         seRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y49si3486114edd.80.2019.02.01.06.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 06:17:37 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 00672ADF1;
	Fri,  1 Feb 2019 14:17:36 +0000 (UTC)
Date: Fri, 1 Feb 2019 14:17:33 +0000
From: Mel Gorman <mgorman@suse.de>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Peter Xu <peterx@redhat.com>,
	Blake Caldwell <blake.caldwell@colorado.edu>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>
Subject: Re: [LSF/MM TOPIC] NUMA remote THP vs NUMA local non-THP under
 MADV_HUGEPAGE
Message-ID: <20190201141733.GC4926@suse.de>
References: <20190129234058.GH31695@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190129234058.GH31695@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 06:40:58PM -0500, Andrea Arcangeli wrote:
> I posted some benchmark results showing that for tasks without strong
> NUMA locality the __GFP_THISNODE logic is not guaranteed to be optimal
> (and here of course I mean even if we ignore the large slowdown with
> swap storms at allocation time that might be caused by
> __GFP_THISNODE). The results also show NUMA remote THPs help
> intrasocket as well as intersocket.
> 
> https://lkml.kernel.org/r/20181210044916.GC24097@redhat.com
> https://lkml.kernel.org/r/20181212104418.GE1130@redhat.com
> 
> The following seems the interim conclusion which I happen to be in
> agreement with Michal and Mel:
> 
> https://lkml.kernel.org/r/20181212095051.GO1286@dhcp22.suse.cz
> https://lkml.kernel.org/r/20181212170016.GG1130@redhat.com
> 
> Hopefully this strict issue will be hot-fixed before April (like we
> had to hot-fix it in the enterprise kernels to avoid the 3 years old
> regression to break large workloads that can't fit it in a single NUMA
> node and I assume other enterprise distributions will follow suit),
> but whatever hot-fix will likely allow ample margin for discussions on
> what we can do better to optimize the decision between local non-THP
> and remote THP under MADV_HUGEPAGE.
> 
> It is clear that the __GFP_THISNODE forced in the current code
> provides some minor advantage to apps using MADV_HUGEPAGE that can fit
> in a single NUMA node, but we should try to achieve it without major
> disadvantages to apps that can't fit in a single NUMA node.
> 
> For example it was mentioned that we could allocate readily available
> already-free local 4k if local compaction fails and the watermarks
> still allows local 4k allocations without invoking reclaim, before
> invoking compaction on remote nodes. The same can be repeated at a
> second level with intra-socket non-THP memory before invoking
> compaction inter-socket. However we can't do things like that with the
> current page allocator workflow. It's possible some larger change is
> required than just sending a single gfp bitflag down to the page
> allocator that creates an implicit MPOL_LOCAL binding to make it
> behave like the obsoleted numa/zone reclaim behavior, but weirdly only
> applied to THP allocations.
> 

I would also be interested in discussing this topic. My activity is
mostly compaction-related but I believe it will evolve into something
that returns more sane data to the page allocator. That should make it a
bit easier to detect when local compaction fails and make it easier to
improve the page allocator workflow without throwing another workload
under a bus.

-- 
Mel Gorman
SUSE Labs

