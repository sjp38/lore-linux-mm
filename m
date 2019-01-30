Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1BB0C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 16:51:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 784652184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 16:51:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 784652184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC49B8E0004; Wed, 30 Jan 2019 11:51:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4A2C8E0001; Wed, 30 Jan 2019 11:51:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEC5E8E0004; Wed, 30 Jan 2019 11:51:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA448E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:51:02 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f17so60423edm.20
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 08:51:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tEm0J8Kge1NuyJMhPil+sEZetfNfj46JhAJCex0yErI=;
        b=DsqZQCLAP4pBrEmFwaYf2X/Mni5vKTMAXJRpADt9vj8ZBz264hKnv4b4t51/m7JBPw
         Ed2jasl31Loa1eoeLtW6711rxlYU2a5RhXlEvmXwxqKxO5F29rdcuQyN074cgzxg3NcI
         /rviaa+M4Afx0X2cOICoq3MFVnLMRStUbnAtnwOozC8TMoiiLqB3b7gupGBr+IaRUM2j
         VUW5poyd7GFW/5Dtpm1I9g9hD1fYt5xmI5Iw84NB8sFAihbpaFlJQD8OsOpw2YsVo825
         j2taoAWzYdNndN6nsEJHLDeIxwoid4jHi7KfW9OrvnQgqZ3xcD/A9+GAjmFitgnzfqkN
         ERSQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukejAyutr6pqqVjm9+6H3bxjNo/EgH7NsHAjGG5JgNM31+p0X9Oo
	8udNO71lNmSxL+LX42Smdk8anzk8WDC8P+HXONDhM1XD66FXOZhZBuIlMpi3yrJ6B4sEFPHYY5C
	PSaS97FP8RTCnyM8ZW5AZi+wd4qfMxs64nSPUqlPoD9ROMXWqI0PnV/WxVojcqOA=
X-Received: by 2002:a17:906:76cb:: with SMTP id q11mr27170024ejn.49.1548867061942;
        Wed, 30 Jan 2019 08:51:01 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7g+SsDS7HX2b23XlGmjUg7P/IG8NKC6LNb3fDyxtXb+vf+tbyboKr/ldDwnILYFemKcUu7
X-Received: by 2002:a17:906:76cb:: with SMTP id q11mr27169973ejn.49.1548867061023;
        Wed, 30 Jan 2019 08:51:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548867061; cv=none;
        d=google.com; s=arc-20160816;
        b=XPmkH36UtEvWymOlf0wu2resGO7oDYvFimu9xqlpO9J7a4TL4UviJ/eIx0rzcwJNge
         REfZSOzRyysesdP39wYdpyvKY9izI/gtXeHpnWzVyguJlxGjuvOjJ/sKlJJazi9ykTFi
         wulO9Wy84JixdEwD0HKD10H2/d/6wQ/nzU1ZWs6vYhzT7KYZlcOJoOounfg5UjUz4MXZ
         vj16rb1xrZPg4f9GJh9L88T7WsQAv34MaAHTUxceA+AuhJTJvEo7mHOPk1zwxSqLQH4j
         pIHNak/W6J0YaAOgVoqx/HL8OWElx5eRRxfd59W4UU34g3AFStotU8Did2XnuO8LeN6i
         KwOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tEm0J8Kge1NuyJMhPil+sEZetfNfj46JhAJCex0yErI=;
        b=tvzbgA8njp07X17931k1HNhFjA06ZUR0NYAzS8ixuYaKWJP11DqfEhg0Dl76Ysj9Ro
         tgx1XohoAY54POLhJxXWP6kpS598/Z7D0ppuwMf68H3tj7n9IXftLWpgT5RSlf0M2Dfz
         BOavtslbxks8n64tqXEyEiED2QXqGl5aB0lLAZ+9OXJ2PK8MUz3O1zt0hBxIjsA9dyzy
         fIItsVQk3hn5tX3xS4TLgUdGbpC11SsyTyGljTt2N/AmclZJYvP0n7FFTFvYvOfxH1Cu
         OA9U1tRks2Qw/SeUuuHcL/alqqE83SUxaGKPy0aUPP1qKZX3I03ZFizvx0U09EZij/4F
         3hQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a13si755003eje.309.2019.01.30.08.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 08:51:01 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 42860AFCE;
	Wed, 30 Jan 2019 16:51:00 +0000 (UTC)
Date: Wed, 30 Jan 2019 17:50:58 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190130165058.GA18811@dhcp22.suse.cz>
References: <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
 <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz>
 <20190129145240.GX50184@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129145240.GX50184@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 29-01-19 06:52:40, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jan 29, 2019 at 03:43:06PM +0100, Michal Hocko wrote:
> > All memcg events are represented non-hierarchical AFAICS
> > memcg_memory_event() simply accounts at the level when it happens. Or do
> > I miss something? Or are you talking about .events files for other
> > controllers?
> 
> Yeah, cgroup.events and .stat files as some of the local stats would
> be useful too, so if we don't flip memory.events we'll end up with sth
> like cgroup.events.local, memory.events.tree and memory.stats.local,
> which is gonna be hilarious.

Why cannot we simply have memory.events_tree and be done with it? Sure
the file names are not goin to be consistent which is a minus but that
ship has already sailed some time ago.

> If you aren't willing to change your mind, the only option seems to be
> introducing a mount option to gate the flip and additions of local
> files.  Most likely, userspace will enable the option by default
> everywhere, so the end result will be exactly the same but I guess
> it'll better address your concern.

How does the consumer of the API learns about the mount type?
-- 
Michal Hocko
SUSE Labs

