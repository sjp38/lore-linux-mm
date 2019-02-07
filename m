Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A259AC282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 10:27:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6801A21904
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 10:27:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6801A21904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F178A8E0026; Thu,  7 Feb 2019 05:27:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC81C8E0002; Thu,  7 Feb 2019 05:27:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D90708E0026; Thu,  7 Feb 2019 05:27:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9277C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 05:27:54 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g9so7606120pfe.7
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 02:27:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=U+YCRhzbe5qcRlWx/bb45bHeoKIPQmgyx5Mpe7aHkxs=;
        b=fJ0bFJdidQgrQ5r+p94ZOlgxdzaLODRQWQ2kTBuSu4RY+leAcFVn0Vq6zsrTZVXPhQ
         MJR0xTnZrWlEQO/TkW40wOUjtk18dRbFZ4rfQofhpCKECfmxG85/sMBCLolAI+V2LUwq
         XLkKESVT9EXxfzg/zvmcoZ72YOUOIgqkJAxzYLb61NuXMTtv3IVYQuZQUcfWxvcuigNR
         hsDnYtv7b2xY3SH3MTfMR5C7Dh4LvNpmHvejaQOIAyddhFmPkeOYOlICGInrWQzsAS54
         DNKrvtapCUyjZQ2glvoKWLB96z8nFh2VcrSuPHMqAA1SAksyxjpWGMZkA3x4Xhm1ZqG2
         lKPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuajWi/tEMpv/Isz69TYdbtbDzQzmUGgnDBNCJVswey6MgR99Rqe
	WwM5fQ05QFreFbdOL6F0k3kQmAjmAsBNPb8G7MyvvAtEksJSElF0/sYvn5b7FjYge/qBUKxj5nz
	XUQ3f8Xa52ReU5NJqcTqomKz0Kzk29fmWMiIC7gR3zxciqsBw0VJiC/qNwPKxDm6dEA==
X-Received: by 2002:a63:c401:: with SMTP id h1mr11735432pgd.62.1549535274162;
        Thu, 07 Feb 2019 02:27:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYzQYumcGlBbVwlJvt0DGfj2JrPlEyJN+zJw52rXsNtnYT1MDW7RdMTXOt+ZzH/rxP/pOEc
X-Received: by 2002:a63:c401:: with SMTP id h1mr11735388pgd.62.1549535273454;
        Thu, 07 Feb 2019 02:27:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549535273; cv=none;
        d=google.com; s=arc-20160816;
        b=eT8J9Mq40YhRI7tigxEGtE1IrC+eaaLHIJxTVOs8mcLXeSzjj5+SCZ86Cyrc2pC6tW
         MxNmVPcShATZ5P9bx8c3ApCcvaGLnJI8en71/t2zc/Oe7nPfhzlWbC2EIWg9H2gvwJuJ
         cilgxwpt+1vyNqLogBx0rgzZl1fFge9MCK5su41N7/kUuzUFXVOVuf41dbtjLGl4Jzw5
         yToocLc9wLNRz950kXf4rA35H0urAVU+OI9sRXBHqQXkjy6pATGe3foyooSmcB42XPtW
         v3gzMyDVZ+S4CI8ILFT8d7wwn3VYSJt5Id4r1Vnm2b4dUeiTnXZ4gP8Ta84wFM4MEG23
         8Yuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=U+YCRhzbe5qcRlWx/bb45bHeoKIPQmgyx5Mpe7aHkxs=;
        b=L8tIOKbgni/hW4j80QTPRcDJsclAGAZuoKjAqq+yR+mM0PYM56sQT6h7JFbrYHxF3m
         1F5U8LyJHlpDEKn6QW9/x5nqKVWYkWoQmKD/6bHMb1qJoAjenD2nNue7G7bo2DGy2qQJ
         pMTybePXZg+dQ8pFS8uGsnuEm3uRmm6irOzKGrBKcRlZuttZgOlndKfo67vGmlJiZzDW
         NpLmWFzNFnhS/0jA4zEPDZ8mcmY8R3jr3FIci8wkoRZ0DC6QF9iHA/wOMMhwTHYpDc9e
         YMuaM50omv79ghyyhBeZGvT8H/v8TqjJoxk3qb5K4EkMpSzXNxiAhrrYKLb15ZcXSf/y
         L4Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q90si3130493pfi.214.2019.02.07.02.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 02:27:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 87F11ACC7;
	Thu,  7 Feb 2019 10:27:51 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id C6B041E3DB5; Thu,  7 Feb 2019 11:27:50 +0100 (CET)
Date: Thu, 7 Feb 2019 11:27:50 +0100
From: Jan Kara <jack@suse.cz>
To: Dave Chinner <david@fromorbit.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>,
	Chris Mason <clm@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Message-ID: <20190207102750.GA4570@quack2.suse.cz>
References: <20190130041707.27750-1-david@fromorbit.com>
 <20190130041707.27750-2-david@fromorbit.com>
 <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
 <20190131013403.GI4205@dastard>
 <20190131091011.GP18811@dhcp22.suse.cz>
 <20190131185704.GA8755@castle.DHCP.thefacebook.com>
 <20190131221904.GL4205@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131221904.GL4205@dastard>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 01-02-19 09:19:04, Dave Chinner wrote:
> Maybe for memcgs, but that's exactly the oppose of what we want to
> do for global caches (e.g. filesystem metadata caches). We need to
> make sure that a single, heavily pressured cache doesn't evict small
> caches that lower pressure but are equally important for
> performance.
> 
> e.g. I've noticed recently a significant increase in RMW cycles in
> XFS inode cache writeback during various benchmarks. It hasn't
> affected performance because the machine has IO and CPU to burn, but
> on slower machines and storage, it will have a major impact.

Just as a data point, our performance testing infrastructure has bisected
down to the commits discussed in this thread as the cause of about 40%
regression in XFS file delete performance in bonnie++ benchmark.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

