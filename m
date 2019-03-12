Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60C03C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:44:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24DB62054F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:44:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24DB62054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92EC68E0003; Tue, 12 Mar 2019 12:44:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B4A58E0002; Tue, 12 Mar 2019 12:44:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 755BB8E0003; Tue, 12 Mar 2019 12:44:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 194BD8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:44:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t13so1367235edw.13
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:44:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=w2+DN2EdxMC+DqJF2V5AG1mbh5gPVmAecYxS5FTayVs=;
        b=WH/MsIGQzGaFt8gKPLkRv4ckdBIAUxiJjLtBnCOPLW77amuf9goNv7UYraQcJD9Icd
         z1kIrIm12dZOUn3MCZT5/SST+IxZqHA2eIeYDk2kOfMMaUC4+d+U6GV3Suw90Pa1lnul
         b2pm5oth2AzgH7NRmlc4R91ucN3InzqhnBiBXKwkwaGCDkb4lJBHQAqpCGsNxVI2AHmC
         o0cmhd9DSyHxn9/cy5Yhz3ZemMjqRYCsJDY7qw6MIlFd2nwwaxzQmL90cYET2S4J3Qt6
         KmOHomNkPHqjArffQNNWyQzH59D/gLzfZDlO2MJ40BPgeHEPjEDdkrcz0lkb+BRLrxL3
         6DeQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWINLyR3Rv/iygff7hKdNs+wDSvRZ82k8jC0zZLHBnEEE1fgTdw
	P0uvaIu0srEq7iLf6Oe/ePvNdSXJgsBR0Mt0ziWWJ8+FzsxqcX8KEB4Tnwigr3UNa29l1yfF81T
	snHXdNMIrRPTeIiWjffm1R+GVsOsjSl1YIMszq1HvTyzAvlYQh4+gm2RkA1ciSXM=
X-Received: by 2002:a17:906:4688:: with SMTP id a8mr13929599ejr.246.1552409064610;
        Tue, 12 Mar 2019 09:44:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxA2az3JUAR45hrw4RkqwIZi0OJbmzX61haqKFwOADrKmcld61mQgBAVH2y+1FwwbLIGHQ2
X-Received: by 2002:a17:906:4688:: with SMTP id a8mr13929561ejr.246.1552409063736;
        Tue, 12 Mar 2019 09:44:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552409063; cv=none;
        d=google.com; s=arc-20160816;
        b=nGMlpU9cGmd9CEj3JrdkbY2TbrtftF0pnBMer84KJ7OSxE9Irt5dEnJmpnk1nUKNgW
         +nSrayuB3WOI8G3GMgvnN+ysL84E5TkcWDblSnIOD9HH36Pq1Vu+jSyT2keykF8BqALn
         Jy8s7qNqZEjmjw3FlYWB6xI8iwmR3Xm0VV+Iep6SheyRcKe4vBh8YL7TCwmKp+Kpt5B5
         KrqmqOj1Bv3UjjTbJO280PDLd014VS7QY97h5uszLz1IL/MK4y8+voGv1pHJcIARDcKj
         tJTKKW5nME9eavBQMWiI9iyQjKpniHfCeKcBxV5AP9fZsBJKOpg+qkmWGIdsrgiRYLmZ
         /YMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=w2+DN2EdxMC+DqJF2V5AG1mbh5gPVmAecYxS5FTayVs=;
        b=CVSKuQY1Bz2xKQRh8L2MyASlgmXcFnAKPRZ/KJ1orqwOXBhpAPG4sn8n98lroO3gJ1
         7gI+ng+7nLUh1B7L1K8vfrS84EcxWs+EHbXdzEtszr9Eu67Z1ApNNfLJ2qnLEpCvR3vd
         dTx5c1906EDcI7u36m7+v9uQ1jh64bO5b7M2ga86K173toAlrNPuG0p/VVF/9o5Wa4G0
         gvNysf32G53JNdRzv12aFbyjWbpr3OC2/sU3HKCnDZnFVsc0Q/vaR9M8TwEP9DDUrVyQ
         Em5Y0XYnNSUDAfPN5Oe0nuWMjxbFr0NkWfhcZ7Fn3JcI8TQMoN4u4mbninnR1Z3b8AlK
         HNbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si1747237edh.232.2019.03.12.09.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 09:44:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4E0F8AF0C;
	Tue, 12 Mar 2019 16:44:23 +0000 (UTC)
Date: Tue, 12 Mar 2019 17:44:22 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm: compaction: some tracepoints should be defined only
 when CONFIG_COMPACTION is set
Message-ID: <20190312164422.GD5721@dhcp22.suse.cz>
References: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
 <1551501538-4092-2-git-send-email-laoar.shao@gmail.com>
 <20190312161803.GC5721@dhcp22.suse.cz>
 <CALOAHbBR119mzbkkQ5fmGQ5Bqxu2O4EFgq89gVRXqXN+USzDEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBR119mzbkkQ5fmGQ5Bqxu2O4EFgq89gVRXqXN+USzDEA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-03-19 00:29:57, Yafang Shao wrote:
> On Wed, Mar 13, 2019 at 12:18 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Sat 02-03-19 12:38:58, Yafang Shao wrote:
> > > Only mm_compaction_isolate_{free, migrate}pages may be used when
> > > CONFIG_COMPACTION is not set.
> > > All others are used only when CONFIG_COMPACTION is set.
> >
> > Why is this an improvement?
> >
> 
> After this change, if CONFIG_COMPACTION is not set, the tracepoints
> that only work when CONFIG_COMPACTION is set will not be exposed to
> the usespace.
> Without this change, they will always be expose in debugfs no matter
> CONFIG_COMPACTION is set or not.

And this is exactly something that the changelog should mention. I
wasn't aware that we do export tracepoints even when they are not used
by any code path. This whole macro based programming is just a black
magic.
-- 
Michal Hocko
SUSE Labs

