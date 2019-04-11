Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B926AC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:27:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B27C2184E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:27:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B27C2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E49736B0006; Thu, 11 Apr 2019 08:27:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF8C26B0008; Thu, 11 Apr 2019 08:27:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC0C06B000D; Thu, 11 Apr 2019 08:27:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9583A6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:27:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y7so2999084eds.7
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 05:27:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q/ddM5G9uCXflEUVA6pnfa6HefwXydtjfEVrmmBQ05w=;
        b=nemR2CL2wiE1LX49tXXBBvygDwcWkIO/guOXds3fhM1vbtxW0oxVuJlFfYgpg9dDy0
         dvsRteQC2uRJr1WgTI3Bl8ezZFibziBtXYVKqH+U0rgRBpLznLG02pCAp6jkK5c+DFOM
         L2Vbc97iOMvPBsbpsugijY2qIF43bLsbRIwT8omufim43RObDCUkCJy7wW/ChdFqplT6
         u1sIx2m2PKVHMUoujP0qJWjpgjhGU0cbLsfGK89knOxpk0SQVRrxzba7XKVzUQ5YQaat
         iBT5xsg/NqDU16u90tzTe6Z8a6OcFwgiBgXagUyH7g26QcaNN3SjiFx96NQaIMigKvcs
         eSFQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWSI+HFPGw8cfBhdKaEJNxYdRCIn3PRj85ADBgXXasdFUfdB1Ax
	myaSu3kTsjIa7cGvtGim+jg+5+wyLSxM8w6AKBv1buWfw/gZd7I9/FdhYLjze6G6LqBzitDJbGm
	M3+mCghFVaRUm+Nq37V5TVz/xA4xFgjcrlptsoZf+M1zpcI3FT0ylZvq/hf/Iuls=
X-Received: by 2002:a17:906:9157:: with SMTP id y23mr27586422ejw.240.1554985621165;
        Thu, 11 Apr 2019 05:27:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6HOUpjXVFF+LujgEEsRhxTK0i9/1XistSFVx1QNrYDJj5pDJAio+8K/Uu8/8NqkuHRp4C
X-Received: by 2002:a17:906:9157:: with SMTP id y23mr27586389ejw.240.1554985620437;
        Thu, 11 Apr 2019 05:27:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554985620; cv=none;
        d=google.com; s=arc-20160816;
        b=TKys6NAs+IHGO4fJEx4X5tVffuZjQW7KNkeXiacV+nzSsFJJYWDvSaroo3jwNdfveZ
         sps2wRfQQIX62B9du7dgd/3y9f9xUI6/iTnMFd8ITd4rmg+vWKvQT6eERGROmdsXuZ05
         nsHRPQ5ScEb86m9gWuib9bYObkFFTpwhT3RCTJA8BMYB0ZvCQ7LHtpu0ElNaQVvO+VsL
         EoA0AdIyYH42xYRIVDPHJSO+nwOV7k1qf7C/+VZiHTLsaV5I60gTTji1fFcUHmplCr3O
         J7fdcfIlsuSbegXOS2o2gmRi/aYc3oTn5bb5c/Yu9NUPRwVP7CVvvmwGwsGyWqbGqvEn
         8FJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q/ddM5G9uCXflEUVA6pnfa6HefwXydtjfEVrmmBQ05w=;
        b=uknksPwqLryV1aBjphmtOYMy9rxSQMi2e1Uv32rdSE8XAuedVhGfTQ/gGQdxzw8vQH
         FSIITSbkzlHh5qtRqH1j8aUYs8qShBn+nZw8e7eLjyPSCXig5ntRvC5ATIhwGouB0wbr
         aP+IyZCEw7O+CtAMUzpGlaq/WgXjR4VpgWqWrYJf58IS6grp9baZA8Az4Hqs59DrhiO9
         JLA/xdF/n+8602G8K5qc2hJY1vjdAqZ2HqSxkxk+pg4bf79Q25hoYPdAMCleFieUI3m4
         xfrVe7VAOERjPD3HR5j6GoH7bq6/9NKacEtksqiWdTNihDRLV4UTi5jtcbhuyV0V7oD6
         iDJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2si559692edc.46.2019.04.11.05.27.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 05:27:00 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E7CC7AC5B;
	Thu, 11 Apr 2019 12:26:59 +0000 (UTC)
Date: Thu, 11 Apr 2019 14:26:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: hannes@cmpxchg.org, chris@chrisdown.name, akpm@linux-foundation.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
Message-ID: <20190411122659.GW10383@dhcp22.suse.cz>
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> The current item 'pgscan' is for pages in the memcg,
> which indicates how many pages owned by this memcg are scanned.
> While these pages may not scanned by the taskes in this memcg, even for
> PGSCAN_DIRECT.
> 
> Sometimes we need an item to indicate whehter the tasks in this memcg
> under memory pressure or not.
> So this new item allocstall is added into memory.stat.

We do have memcg events for that purpose and those can even tell whether
the pressure is a result of high or hard limit. Why is this not
sufficient?

> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
-- 
Michal Hocko
SUSE Labs

