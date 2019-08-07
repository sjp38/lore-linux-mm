Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84988C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:17:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50ABD21871
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 23:17:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50ABD21871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9B256B0003; Wed,  7 Aug 2019 19:17:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4BE86B0006; Wed,  7 Aug 2019 19:17:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEC9C6B0007; Wed,  7 Aug 2019 19:17:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 78FAB6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 19:17:56 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so54259666pll.22
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 16:17:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8e5UYK7tmtxZx7Mc6TvypuzxakJP04H3mZpgOtQtbA4=;
        b=Y8AqT2nnHYu9BW9A6pue5bq6VhkxdZs/sKZy6r/lEo3E7cHiH0MRXuNlwuGSZmyY1a
         jWV5DekqBepV97iCvjlJK7AuY7gdWiO3RNCuAfPZKSDat3Y2YC7MaZTYLumLk4G+Dw0s
         j3KtlIlq5FIUVBEyL4t0Qhd1zKmipR1ABd1cwb+URQZShBtx0zBrmIBzluZ7lYZnqmVA
         p+LFJu1wes050K/OML2hJwYeSZOfac56tpjavqvbBnBpCq8rIP5bE1J6L71KUC4IomPf
         yRz80UVIU/TewlYk+zhQjze4AzJT0DTtHiDu59hlJkqaMGGgbsoMvvy/W0fzZiH+kYom
         gEPw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAX7+Jey33kAUFJRXzOPtNOCQvFyO031+cXq9ZGO4GpOxzAn++e4
	XPJ9EFUtarWlEZuw/mtTBizKHvnGFC7uUxNaNoQRC0RhBT9vD5lOxyVVjS/HHvTOOv8izUShYh6
	6tFEyPotG90PZTJT9oUKmXONfkVFqoqNfJASpa+xq4odHOr+S2ECiieKjjeauhBQ=
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr10411918plz.191.1565219876062;
        Wed, 07 Aug 2019 16:17:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjGH/006PnOcyb8Rx6o/WTVurpVK8IQ9hLTKTb3LLgdq0d73IZcg0+vyrI/v3D4hyfqxwL
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr10411887plz.191.1565219875377;
        Wed, 07 Aug 2019 16:17:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565219875; cv=none;
        d=google.com; s=arc-20160816;
        b=gbw8RPIcMf1OkrwrQydqHOXKptHc4jhm4gQOiucnO57Q1iL3ILfPEUuv40/d3IhV2J
         /PENBmNTVtn6QTFXRcx2L2uor0ypVGuJo+uYweeCj7dOgjdiEcHzYAWN8ZS35oqOTONj
         4+32qJUhZ7nCDIOIIErvh993I3u9RVTikM1XRBmlNL0zNK8kcOgm06D5xKFiQlCtFprH
         pEx304o2U6IVDc/IIOlL6UJMHBRLjjd9+IBW2Xlfq4YouIpzmvyUGG+ka7AIeSyTpDCD
         4UFyxKitEm7LuLOx6Ji6k2MADsUlXo0g9Qe7/0kmflLU5XsVRS/WUbZHY1xZXFvMnShW
         g0Fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8e5UYK7tmtxZx7Mc6TvypuzxakJP04H3mZpgOtQtbA4=;
        b=wR7ADdLqubzNkIN03FRXHfsQQGOicCuJfvwok8kn4CaWpJeoPcs3EjNDpE9x7vUe9c
         N5Rauvi1GJmsttLwdman7UFRe6yr/C9jiuZSidgd+wX6D0iOLvsVgKkDsJdwq7zp3vVK
         8YVVRd6VdGxOAKsXhinDjJWOvGV7ignoo17zNFCkw71NZOJJlIpM0gyqHH1tO8TkjAc2
         lJdYJFd2e64Lf/XyR1y8tFzJDpInmPKfM2XAdl6iUB+i5QnK4QyhiH4vQdk0OMfeER9q
         ajhpEUSKq0FjyHkaflqINHPNF7AYNckqfXELg+HNvrVSmyDBCHg2gZfJWWXpaJl32e0m
         uxTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id d7si50062398pgv.86.2019.08.07.16.17.55
        for <linux-mm@kvack.org>;
        Wed, 07 Aug 2019 16:17:55 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 19A37361CB0;
	Thu,  8 Aug 2019 09:17:54 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hvVAl-0006Iz-1P; Thu, 08 Aug 2019 09:16:47 +1000
Date: Thu, 8 Aug 2019 09:16:47 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 18/24] xfs: reduce kswapd blocking on inode locking.
Message-ID: <20190807231647.GS7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-19-david@fromorbit.com>
 <20190806182213.GF2979@bfoster>
 <20190806213353.GJ7777@dread.disaster.area>
 <20190807113009.GC19707@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807113009.GC19707@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=LIETh8aiTdfSQb0hYlUA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 07:30:09AM -0400, Brian Foster wrote:
> Second (and not necessarily caused by this patch), the ireclaim flag
> semantics are kind of a mess. As you've already noted, we currently
> block on some locks even with SYNC_TRYLOCK, yet the cluster flushing
> code has no concept of these flags (so we always trylock, never wait on
> unpin, for some reason use the shared ilock vs. the exclusive ilock,
> etc.). Further, with this patch TRYLOCK|WAIT basically means that if we
> happen to get the lock, we flush and wait on I/O so we can free the
> inode(s), but if somebody else has flushed the inode (we don't get the
> flush lock) we decide not to wait on the I/O that might (or might not)
> already be in progress. I find that a bit inconsistent. It also makes me
> slightly concerned that we're (ab)using flag semantics for a bug fix
> (waiting on inodes we've just flushed from the same task), but it looks
> like this is all going to change quite a bit still so I'm not going to
> worry too much about this mostly existing mess until I grok the bigger
> picture changes... :P

Yes, SYNC_TRYLOCK/SYNC_WAIT semantics are a mess, but they all go
away later in the patchset.  Non-blocking reclaim makes SYNC_TRYLOCK
go away because everything becomes try-lock based, and SYNC_WAIT goes
away because only the xfs_reclaim_inodes() function needs to wait
for reclaim completion and so that gets it's own LRU walker
implementation and the mode parameter is removed.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

