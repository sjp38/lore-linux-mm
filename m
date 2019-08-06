Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDC3CC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:35:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A081A217D7
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:35:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A081A217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C76A6B000A; Tue,  6 Aug 2019 17:35:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49D046B000C; Tue,  6 Aug 2019 17:35:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B3566B000D; Tue,  6 Aug 2019 17:35:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 057726B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:35:03 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s21so49042558plr.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:35:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hcKtHWLzMT1sAsPcpTTLuTPqh6Fqj85o6v+fD64k/LU=;
        b=SRXzDZRRHzBBn5VoXYiwLGj5vMDeGsdOnL2d8CV5WOLp9gxnH2g58m6xzDU3/sHM45
         C7cujHOSBdnPU0QhJ2J2o9nEo95pOYuUMqdKS8mmsEI5gzlgnXrVwi0Fzat1Yjcay3r+
         PBpkw4LSxI3MTMkQ328EC/2tSBtEe2Ns4tVD1bRT4UXmhpJ1fDlSjCbq0KaOCfNKiTvm
         i/ZOU0nFpMLI8zROs7sfoNPoXO3rxI4EVmKmxJ8+1D1i80RZQzhArKeky3SewuXRSuwV
         d8OT1RPSL217PWVDJSyUvdOkvGYmlfstED0yk21u0zUgTvl7Z7wdzn3eZKdrsoyojME/
         JUZQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVcQ/iKzbNeZ4DM5zjQmWeyU1P7aOmwD94xKb9vKMCEFKxWyRpG
	5gDl8js3PMbQ8kBb0NNHbIlRRZKBF37c2u+QoDpIqSYbN42uWZrnrNkvptoEbdZkpBjXbR7V6Ep
	CMav94UytOONmed0lr+mL73yTb8d8UlV8z4pezxGyWpR9UPRLZIsr+K4XckrI7FI=
X-Received: by 2002:a17:902:bc83:: with SMTP id bb3mr5287141plb.56.1565127302708;
        Tue, 06 Aug 2019 14:35:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkcfzK23oVrXm2mUncah3E4LA6OKEPGFlEsLXRRrul5Zj+DKsVI30wma9AiInN6WvcAxmq
X-Received: by 2002:a17:902:bc83:: with SMTP id bb3mr5287094plb.56.1565127302018;
        Tue, 06 Aug 2019 14:35:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565127302; cv=none;
        d=google.com; s=arc-20160816;
        b=frH2ouFW79Q1R/MQBbQpLgAzyhsxSuSmlaLC8yxSqE/i76hGj1WXdaOspuDxsoaRFO
         WvAZKSRMWTDz10Z/E0hLQBRY/5rdnVxhiVHbcAf4ILgQeXOtVGEeu9HdBKaiszyBvOTf
         NqF0O8vx3w/UiKaq3P7zwDpm/x5Dsa2s/8D0WShy13DcdMNXG+rpnnpCk6uPmgoN8j3p
         arkoAibg+miqkoNKUBOZzQZXKXTdzj6WF/wN0bpJVdhZo/NWHS4L0IRIe+omvOtYkJNG
         vvi57ctFKesPoftP92dWqMrCKFtjAy6AI/1R0wiIYbhDbqaEAwuC0uPZbroAc7jUn3BJ
         JD4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hcKtHWLzMT1sAsPcpTTLuTPqh6Fqj85o6v+fD64k/LU=;
        b=Wit5+IUS43CphW0JcmFv+M3Oby+uSpxzlKZE4iIIv+TF04d5/ny+7P9qyHIUcxoFcG
         PKE4UXPk0op5/OPZyegz4hkQdgdYyo1lsqsCNsmCi4P04/TMg2k9TbMaYPpVlzeCa1VN
         tBdrayiHAh+73EnkiswJ+B+1mmjJki+rrz9nVP4j9a8hp4YgwREWz0/Eezhb2Txiechh
         HFLdM6aiADOuXZtCxIsxhQsUcwlEPHDugJbVUT0MEUDIWl6RJsu2t45u6Qb7FCB+pKUA
         QDmSqLXOTLz+0Q1Bh/gPi0kXi6WjxtGaX1r5PqT9fk8QSDKAgnFbBiIQdWROp5GV1E/L
         WV2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id 3si43632598plh.265.2019.08.06.14.35.01
        for <linux-mm@kvack.org>;
        Tue, 06 Aug 2019 14:35:01 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id A0FAD36124A;
	Wed,  7 Aug 2019 07:35:00 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hv75d-0005Dj-JD; Wed, 07 Aug 2019 07:33:53 +1000
Date: Wed, 7 Aug 2019 07:33:53 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 18/24] xfs: reduce kswapd blocking on inode locking.
Message-ID: <20190806213353.GJ7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-19-david@fromorbit.com>
 <20190806182213.GF2979@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806182213.GF2979@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=5n85yxmU3CNEWdoKYM4A:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 02:22:13PM -0400, Brian Foster wrote:
> On Thu, Aug 01, 2019 at 12:17:46PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > When doing async node reclaiming, we grab a batch of inodes that we
> > are likely able to reclaim and ignore those that are already
> > flushing. However, when we actually go to reclaim them, the first
> > thing we do is lock the inode. If we are racing with something
> > else reclaiming the inode or flushing it because it is dirty,
> > we block on the inode lock. Hence we can still block kswapd here.
> > 
> > Further, if we flush an inode, we also cluster all the other dirty
> > inodes in that cluster into the same IO, flush locking them all.
> > However, if the workload is operating on sequential inodes (e.g.
> > created by a tarball extraction) most of these inodes will be
> > sequntial in the cache and so in the same batch
> > we've already grabbed for reclaim scanning.
> > 
> > As a result, it is common for all the inodes in the batch to be
> > dirty and it is common for the first inode flushed to also flush all
> > the inodes in the reclaim batch. In which case, they are now all
> > going to be flush locked and we do not want to block on them.
> > 
> 
> Hmm... I think I'm missing something with this description. For dirty
> inodes that are flushed in a cluster via reclaim as described, aren't we
> already blocking on all of the flush locks by virtue of the synchronous
> I/O associated with the flush of the first dirty inode in that
> particular cluster?

Currently we end up issuing IO and waiting for it, so by the time we
get to the next inode in the cluster, it's already been cleaned and
unlocked.

However, as we go to non-blocking scanning, if we hit one
flush-locked inode in a batch, it's entirely likely that the rest of
the inodes in the batch are also flush locked, and so we should
always try to skip over them in non-blocking reclaim.

This is really just a stepping stone in the logic to the way the
LRU isolation function works - it's entirely non-blocking and full
of lock order inversions, so everything has to run under try-lock
semantics. This is essentially starting that restructuring, based on
the observation that sequential inodes are flushed in batches...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

