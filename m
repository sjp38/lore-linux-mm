Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15163C282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 00:57:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8BBB217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 00:57:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vqbDdCyO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8BBB217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F9AD6B0005; Thu, 23 May 2019 20:57:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AA706B0006; Thu, 23 May 2019 20:57:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09A3A6B0007; Thu, 23 May 2019 20:57:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C33EB6B0005
	for <linux-mm@kvack.org>; Thu, 23 May 2019 20:57:40 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x13so5077649pgl.10
        for <linux-mm@kvack.org>; Thu, 23 May 2019 17:57:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fE1Rg3lQ47GNlTN+vqh5pG95EpB4EK63ZZOQknX+emI=;
        b=bXALNcdu4Jj8D3DXuWKEjlO0AC7Gby6ZhXGEdTKEWP5VGtmb7ZdqimRIG7CPVoPHMT
         6TfBpptf9KRAZVyMBFKgCclMvsz4InIW2hk+uYwlWFpfmyPQhuIZppgtCe+zJ0z+8iE9
         nPQS3+9SBrC4/i8h5H4KmrGe/Cfc9SnMYisnr8ORO3CRKc7G/mUqQPpZZQiyIK5jS2Pb
         s6psU1WOPNHuEyTp2+dcvnA3FCXczHk6n814lu3JS8mbvIf27t1wAdx/tf2HSV7BzcYS
         O+srZYvoczKnHiASMEKdmD5QcOdoCfbyKPVEl/YrCRn0WkUfQl/YllDrYpq96M/x7wsM
         wd8A==
X-Gm-Message-State: APjAAAXpB/hENazXky6jzzfwOSwCrJdXTjNGgTupTKobSMTfaFseMlh2
	oVy2HtcHODmB18FSq02AfDxU2eGXiTX9/4fnekMCqomstOkPjdCjg4zNyuTjzIK7LcTgJPHlhf8
	DzX9WMoWAG0D+JwO+hMLgHlaTPdxD+mLVmESmSe7X9rR8Swi6oQhZ3Q2xqPTBJMtDXA==
X-Received: by 2002:a17:902:bd06:: with SMTP id p6mr28903873pls.112.1558659460248;
        Thu, 23 May 2019 17:57:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+N9TPJRa3kq5uY6QJF10J+Kvlm5ptkQugToDpk9nR5qsUFXUCYFHrmQgHNVzj0N8OGmHr
X-Received: by 2002:a17:902:bd06:: with SMTP id p6mr28903789pls.112.1558659459398;
        Thu, 23 May 2019 17:57:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558659459; cv=none;
        d=google.com; s=arc-20160816;
        b=IZM3U3wZsL380agzAjnVITl8CCXIIZuiJSpdVrWxez6Rj+qO0nhK8Wnk30WhGiu4mQ
         gQOWpbH9whhQcZWwCOxIDjPogKzzm2vacfIdoI3YFgL7OGo1vI/DaB/JAkw4u3gqwm1l
         lZSME78v0Utcjgp8VlixzCK5XQy/2nhoChKSV9cEO90f5vcia77CR/uuVlh5WBhhwkc2
         aR0im/pktYP/Yer433BbSSfP7ETIzp7nv4raCAtblVMpRtDHMszczsnIFwwiWEB/QcXf
         DXgcjcewnwUIP45zdu1xRDgowFx8CpEfmicN1MK9hFBpv1z+QTU4vPieXwKwrjtihZU5
         vcsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fE1Rg3lQ47GNlTN+vqh5pG95EpB4EK63ZZOQknX+emI=;
        b=TQ2vMY1ptPHTrg5USfZzc6DKnnPYHRWUI1Swi0p50zX3d/vm3g57P7YQWchI0ou2+p
         +Z9SIOmRGQMCvpXZOPOm6fYGS5f64l1JbVmFeiVJkry4V7ZV1djPGMCWyYwBq5IqmkO+
         uoMUjwSHM3EY2Y6/5qhkO8RgFGpCx9O9sPelWpuWv7YcgYHrYiYzI8QB84pQNx3noqMY
         X0UBoA72pwtTVGVd9jASuf7pULTSMTQIBllZx+oNXWvXg/AtjH8PWyZ3EE9PxS+Dt2LA
         b0cZAyyV/RjjVfGtr1yefX4kruwdP67kms43dpgx2EcFNDH47G+kmBgOOlJZS+cOjvda
         MQeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vqbDdCyO;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m189si2015813pfb.74.2019.05.23.17.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 17:57:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vqbDdCyO;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 83AB720862;
	Fri, 24 May 2019 00:57:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558659458;
	bh=rxwFvkRmOQ3G9Zun+OPPOUtfAL4LSNfqUCTmRBsD3Oo=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=vqbDdCyOo/WuyU6rByzMzqY0mLECbjGBEKjm0yfhJCvzkT18gZ4eXDMmUSAy4Mvmy
	 d/1bVl3uabwBPZapVb5pB0twkbf8I6uCNMhK70bjUINQxrrUCtG2fnp3kHsFrRzuH9
	 R/MjcQhzatl4pRWR1LiaSHTCkCiRrQqEr+hxLLKA=
Date: Thu, 23 May 2019 17:57:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>,
 Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Zi Yan
 <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG
 <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert
 "mm, thp: restore node-local hugepage allocations"
Message-Id: <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
References: <20190503223146.2312-1-aarcange@redhat.com>
	<20190503223146.2312-3-aarcange@redhat.com>
	<alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
	<20190520153621.GL18914@techsingularity.net>
	<alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 May 2019 10:54:16 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> We are going in circles, *yes* there is a problem for potential swap 
> storms today because of the poor interaction between memory compaction and 
> directed reclaim but this is a result of a poor API that does not allow 
> userspace to specify that its workload really will span multiple sockets 
> so faulting remotely is the best course of action.  The fix is not to 
> cause regressions for others who have implemented a userspace stack that 
> is based on the past 3+ years of long standing behavior or for specialized 
> workloads where it is known that it spans multiple sockets so we want some 
> kind of different behavior.  We need to provide a clear and stable API to 
> define these terms for the page allocator that is independent of any 
> global setting of thp enabled, defrag, zone_reclaim_mode, etc.  It's 
> workload dependent.

um, who is going to do this work?

Implementing a new API doesn't help existing userspace which is hurting
from the problem which this patch addresses.

It does appear to me that this patch does more good than harm for the
totality of kernel users, so I'm inclined to push it through and to try
to talk Linus out of reverting it again.  

