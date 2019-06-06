Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 331A6C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:44:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0282120866
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:44:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0282120866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E1566B027A; Thu,  6 Jun 2019 10:44:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 792136B027B; Thu,  6 Jun 2019 10:44:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65A9B6B027C; Thu,  6 Jun 2019 10:44:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD326B027A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:44:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so4103306eda.2
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:44:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F4AQuU80v3h56DcfEO8zh5yjwJHkOCG34P/wimYaosI=;
        b=kjvJE4OGl5DOYOT+hPWZgHj6e2MAD+bA1IhLi+ZrK55vPSU8eMOeC39pjnimrCDGGQ
         y+OybT5oWDTy7guMp9QrDV+wg/kA3z16qZivvOKVKvCS5Mdolj9Kh/eXp4/OanvtMqil
         +y84HdMOpBtD8IOrIZYgs0kTuWeeueLL8xxXKVQ67mHqF4wxD/M2O5qqu3deVxSgooIQ
         RakB1wR/Cn4aiiHKZekuhnYEsqr2ln1Svgqpn2OcYyiyrofMzpEppAP5V57VeKdpAi6g
         PvU1+npd1SmBNJMXhFI/nLszeoR5a5TtuJTGA9pudYqXZul2GIznFfFtp3THgmDWL5Ra
         pp3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAX33Tv0JP874HorCSADFqGEVO+o6jurnddQvWoB7ZiRBLC6A5HR
	HfEBc0clZFDbPjEjbsZsrz9ziYThd0QCGeU6mJbaq7E9+NV8fy2Akn0azMZfK/uTB9menbOzpPN
	az0od5hQWiD166y/DcUj1XSuA7BvkmzmD5+H/D8xTo7v/Ld49/0QAzEzNgb2zT7HvmQ==
X-Received: by 2002:a17:906:9410:: with SMTP id q16mr6367650ejx.90.1559832285620;
        Thu, 06 Jun 2019 07:44:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4tdf2zfv2bKOcJInoaqrnlJCLKFZOLi9in1c8ZCnM+SAK53EH950CAoVxzoA8geXt7F6h
X-Received: by 2002:a17:906:9410:: with SMTP id q16mr6367580ejx.90.1559832284654;
        Thu, 06 Jun 2019 07:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559832284; cv=none;
        d=google.com; s=arc-20160816;
        b=eMdvZCFig0DT7gjkclogoBYVQQ8hDnquLpjQm50LLYBpuUkkJVj+Wmf8tHd+l+0Ys8
         qLx1oI0+akJk2Cw83tysXlynCl3+oD86/DVhnxRNOgeQoy5MMM8UrwjoMRVHDrhhEbTT
         d2/K28MAe0InxNRHSX20EVswbYpKXfrWO9eLrRxMQ2LvgOXp+KvMVxQtF0hQMtMNvXDj
         Nt7R7bHqiDUKUL1hIYKe6nGl0AFsVaCXS+FbDGp/jQsZoBo0/EyV6deneIHOE5LxP1iu
         OVKfQh7jGOBCsMJIGv7nZoebT58vrCxs1q0+BxIbheKdsFfoQvFlIWxnFsTDmpgnSm2b
         eTrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F4AQuU80v3h56DcfEO8zh5yjwJHkOCG34P/wimYaosI=;
        b=tdwFF+k45/W2XzHitZtQKiVhn/0GcWym5tJ7A2DyEqvP5zR6/LUIsZKcSqcpp8eNo6
         ykiTjys/czrTTRyD3kHRIVJmPSih0/hCK9ps9Y0vwQ/odjyt7NMOrGn1uBXuJ1kqsLgF
         zDEJg4XZvanPfHBplLcbSl7xXRK6gXnG29eL6wcDqH0f176BHTf2yne5T4OMSWluA5LC
         FRXrA3EVBUIRJv3USk2kCLgjFQIO9NnGEnptUhtGjKWDFJb/07q0eM6yEaaar6ZjCnrR
         3Myj4JxBAPORgEtWhBXHSI55IFoAFyg/2pLy2TrjKVERLdDuUzHTkFGyKatGnMrAHG65
         rElA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si1701069eda.200.2019.06.06.07.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 07:44:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 41D40AF1C;
	Thu,  6 Jun 2019 14:44:44 +0000 (UTC)
Date: Thu, 6 Jun 2019 16:44:39 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Bharath Vedartham <linux.bhar@gmail.com>,
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Subject: Re: [PATCH v4 0/3] mm: improvements in shrink slab
Message-ID: <20190606144439.GA12311@dhcp22.suse.cz>
References: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
 <20190606111755.GB15779@dhcp22.suse.cz>
 <CALOAHbDYKL2kSfaf9Z_E=TyNQtGaAUfxG8MkSXb1g0VSkcYzNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbDYKL2kSfaf9Z_E=TyNQtGaAUfxG8MkSXb1g0VSkcYzNA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 06-06-19 22:18:41, Yafang Shao wrote:
[...]
> Well, seems when we introduce new feature for page relciam, we always
> ignore the node reclaim path.

Yes, node reclaim is quite weird and I am not really sure whether we
still have many users these days. It used to be mostly driven by
artificial benchmarks which highly benefit from the local node access.
We have turned off its automatic enabling when there are nodes with
higher access latency quite some time ago without anybody noticing
actually.

> Regarding node reclaim path, we always turn it off on our servers,
> because we really found some latency spike caused by node reclaim
> (the reason why node reclaim is turned on is not clear).

Yes, that was the case and the reason it is not enabled by default.

> The reason I expose node reclaim details to userspace is because the user
> can set node reclaim details now.

Well, just because somebody _can_ enable it doesn't sound like a
sufficient justification to expose even more implementation details of
this feature. I am not really sure there is a strong reason to touch the
code without a real usecase behind.
-- 
Michal Hocko
SUSE Labs

