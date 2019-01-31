Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3199C282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 01:34:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F28320881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 01:34:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F28320881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BDFE8E0003; Wed, 30 Jan 2019 20:34:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36E1F8E0001; Wed, 30 Jan 2019 20:34:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25D628E0003; Wed, 30 Jan 2019 20:34:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D88F88E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:34:07 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 89so1110950ple.19
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:34:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MwHUp2M5vGSEquHAiLMpS8bbA/M+vpcForAR1l/EG7I=;
        b=AJwyd93jAraHVbvCCma2nSWUYTOvGQ7l6VAJFFhcFq6eOV0NVDp9d6G86qQGgT0jaY
         +qjdT1JwmBwniCln2r1yhjsvT36xO5FTFVMS9hrfaaYWFk3j6m6xQBT721vKp/mY4Uqb
         e3A0pMXnsTBjq/thqGZjLU/cduj4R5ah6pp10h8nacEHfOlQmeYGVWP0ACizRam2IUx1
         hF0LutZxkssROKmzBG6QsRwgQG0HdLgBkfDTUVk/SDI9JrKCTqiBBZ1+CgEizkT2Yns6
         qkodDNDVsQHpZ9zHjf37E9j4naexRnH54xUQl6hDYtDGXVTDRabBYlEloSm5N0DqAbTu
         FTzA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AJcUukc7ddLcgzcdtctDAYJP/wMmu7quskyaO0ayqtzHABRkp7/CJerd
	quELFXbnXX3xoDKs4H8bUQsbinMBEgWPPNdx87/EY0U3h3yceyZKF5iNFAyC35+kjUqg0nofl52
	YwOKbGMdKi5mpyAC/TrLmntUMUBQE3ld+4MSOapUibNoh2p4FWwyGLAZs34heGcY=
X-Received: by 2002:a17:902:24d:: with SMTP id 71mr24266425plc.225.1548898447250;
        Wed, 30 Jan 2019 17:34:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4W4kXB5dcaPVl/dD1kGvxenAG64bL6ZoZAHcPfdXmqr8LG8Bv2M9ovUAE12pVj/ulcR/eh
X-Received: by 2002:a17:902:24d:: with SMTP id 71mr24266388plc.225.1548898446553;
        Wed, 30 Jan 2019 17:34:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548898446; cv=none;
        d=google.com; s=arc-20160816;
        b=sBJenyk/uJ74XKk+QUKstYvSzeC4wwMwD+CPngSmLw2TQ7EpirfqpNIRMQPwq1xaCd
         ZqYuv3FQWvGNo/i1cqiqftfm7D07rPdiUoe7Vg7L7HBTCZiz3u1vtJYDufjAg/R8pUca
         3KXGUyeOYYYDXNoSNcy0uQ3aCL6WuU2K2TxjORJnw9vzoYnHaEhIm0ZDl/UADrbpM8dx
         S0Oxk281qATzVG/7IZwky2w8ZSQQCRbXHBB2VLHyDsXJXGmaJkC9EuSkNmBWEzZM5L6p
         0RAgFF/ENsT42DKOg8e8k+0mKCYJVgIx/q2VXxxmfy27mYe2IPb3kZ1154a8ysmc7NGo
         k9tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MwHUp2M5vGSEquHAiLMpS8bbA/M+vpcForAR1l/EG7I=;
        b=gzlDM2wpPdf0LZqjGeaMVzUbMC8macdskZ7QEm6lbISUnACwS+bmpAXL0R93f+sZSq
         xFyGNFKqiMbQugMiqX39o6ihSKpsRXSUAtgJ1TO/51BzixVNo5/WaEoJzJtkBlnPvl4m
         Ma3LYRTGE2ilZFb00DlCGb50wuQgeJkS3E+s0kndBHUYVK401JhB+chNAB7QXIYJgjIK
         h+gAH8F/np5UkMFB8XSEWrvohW8JohtKCoLpCKrX5nSEUCrmb/tOwx+SjTYpiqVpQnUk
         yPWN4FIzGW3CAy5JQwLDAGO9MTcqCFKxqF17YHQzDMJf8IsKIWOVKTtY5sRF+WkzdowH
         um0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id k134si3050699pga.401.2019.01.30.17.34.05
        for <linux-mm@kvack.org>;
        Wed, 30 Jan 2019 17:34:06 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.136;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.136 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail01.adl6.internode.on.net with ESMTP; 31 Jan 2019 12:04:03 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gp1Ex-0001yb-4V; Thu, 31 Jan 2019 12:34:03 +1100
Date: Thu, 31 Jan 2019 12:34:03 +1100
From: Dave Chinner <david@fromorbit.com>
To: Chris Mason <clm@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"mhocko@kernel.org" <mhocko@kernel.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Message-ID: <20190131013403.GI4205@dastard>
References: <20190130041707.27750-1-david@fromorbit.com>
 <20190130041707.27750-2-david@fromorbit.com>
 <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 12:21:07PM +0000, Chris Mason wrote:
> 
> 
> On 29 Jan 2019, at 23:17, Dave Chinner wrote:
> 
> > From: Dave Chinner <dchinner@redhat.com>
> >
> > This reverts commit a76cf1a474d7dbcd9336b5f5afb0162baa142cf0.
> >
> > This change causes serious changes to page cache and inode cache
> > behaviour and balance, resulting in major performance regressions
> > when combining worklaods such as large file copies and kernel
> > compiles.
> >
> > https://bugzilla.kernel.org/show_bug.cgi?id=202441
> 
> I'm a little confused by the latest comment in the bz:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=202441#c24

Which says the first patch that changed the shrinker behaviour is
the underlying cause of the regression.

> Are these reverts sufficient?

I think so.

> Roman beat me to suggesting Rik's followup.  We hit a different problem 
> in prod with small slabs, and have a lot of instrumentation on Rik's 
> code helping.

I think that's just another nasty, expedient hack that doesn't solve
the underlying problem. Solving the underlying problem does not
require changing core reclaim algorithms and upsetting a page
reclaim/shrinker balance that has been stable and worked well for
just about everyone for years.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

