Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB494C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:25:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 841142084C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:25:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="Hm23Ypcm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 841142084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9F316B000E; Tue,  9 Apr 2019 09:25:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E27C56B0010; Tue,  9 Apr 2019 09:25:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC91C6B0266; Tue,  9 Apr 2019 09:25:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2446B000E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 09:25:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h26so290372eds.6
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 06:25:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UYojcopqko36lUtbZDYw6S8V10mvNQWJ/pPg3zMuWMg=;
        b=L9JtDOQnNujFAdWQL8ib6K+bExbi7uAdj2cSyYnfWK6iAg5aB3hChixsQxOho60TLg
         B2f6OTjTVKsyE64rzM3l8fno/NUU8RCfgKRB0M1rc2OAANyfi88LbI5nWMQRtrQupFh1
         zjcX8XkGzHQg7hJqlWs1NI9WOGnrH5JNG0wv/HqXXJ5GLdZMLy7BuKnt69VE1z/Dlp/F
         sRW04QnYQ6hlZtgTJYErPUIJsGTVNaajjpMYCmRGMV9GMSlTQxzaLGoefwCB+XQ0lmT7
         5qzAqtvzVG9qsNVG8s7guicJrrcDJ83KKzhiWk7rV+4DEM/AAl5RdqKKQ0FTrhQW2GHn
         NeGA==
X-Gm-Message-State: APjAAAXoloXvFX0D7csH1P7Z5DzdyPNmey8+Y8hMwWTskzdD423Magdp
	KdM6tBb+phl4UJAnX/mTQ4lmZFzFfjonyKBvWv29wu0jXj3G7NYmWbK5zALB/4b2e5go5025Dux
	yjxSYBJosh7qc2zx4bt1VZ8IellQn8doRbCYfDLuycWvSQ6NRxnGl0rV3y23LDjWOnw==
X-Received: by 2002:a17:906:55cc:: with SMTP id z12mr20599204ejp.213.1554816354038;
        Tue, 09 Apr 2019 06:25:54 -0700 (PDT)
X-Received: by 2002:a17:906:55cc:: with SMTP id z12mr20599158ejp.213.1554816353300;
        Tue, 09 Apr 2019 06:25:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554816353; cv=none;
        d=google.com; s=arc-20160816;
        b=yY9NJFkS+GwrRXHx0fzGigSupsuBsfSQ+eZxv319zmCmeD+1jDpZfmExNBxPZEdrt2
         Hula8y+HpIIc9hXaJ8IPWciydRUVy3PM79m0xRvso7G3tB0DrnNBMLBKKJuw2On6YcUf
         iqXIu2nBAkcrFJ7ccv00FOY/FISoQLm0DE6DWOAKdwHH7WqcOVtOjVNUZy8FLui2o5NO
         Je8NBmMQuUabMyBQinMD+G64Lp275Btxvxym/8BFM9YPnRTKHswsDcApY/wLML+ukfII
         kckM2eAFRHrYeJGdUp6yKP6djHA6jA/Bpo3LAylDfawvqsk4Ktsbxa3pl453Q+pDG0uI
         cwdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UYojcopqko36lUtbZDYw6S8V10mvNQWJ/pPg3zMuWMg=;
        b=0ZjAL08vJPwdsxsOEdwen9QKsRfWnD38r2Z+0dB+ZpPD/so6kgo79GcxqqBWrL5Ith
         Ymqw6jfqlTyphXcCAL2gkP4CqrHOr3WAjySLfByASMAwnknwTmUna/6HMMtrQ1bMuv+I
         JTVyUVNKRi9KEr1kg+xveZZhH0FMURom2pxNUi9e+MmuhqyySHdk0SxHARsRJrwsGXu1
         28ymdfvaqh8NYEeg095e5J1+rmcbrrJ7F257TMbk1CbL/vByP2m1cY3IdJX47XVmJQJZ
         zDSG16xASjoL/dnGeCKgdDfkZfhXj4o21zV8DMsQI0uZOMZZ0pk80wmLHUSa2IUtjM4z
         RdhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=Hm23Ypcm;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m18sor5117493ejs.49.2019.04.09.06.25.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 06:25:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=Hm23Ypcm;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UYojcopqko36lUtbZDYw6S8V10mvNQWJ/pPg3zMuWMg=;
        b=Hm23YpcmKNDc+Fc8CXrifg7gMJqfAbiaJggEzljHOlcg72OQ+zPqhR2ij0x2ZEptPC
         f7J/nyph0oWXN214aaMpXrEbtubEXmt23J60ahM2zJ7HUybuaNnoObFDboErR3x3RnzY
         cP7RUpqxraTPE6kgMARmoS/OVWgQhP0bVfBZA=
X-Google-Smtp-Source: APXvYqyZSjIMq3/+9Sjt8FFiMpk/ZEc+dSLI01wQb8DZdbTz0ugE8WqVDYNjl1UKstZ9dVpjPJ7pgQ==
X-Received: by 2002:a17:906:6986:: with SMTP id i6mr2360338ejr.238.1554816352813;
        Tue, 09 Apr 2019 06:25:52 -0700 (PDT)
Received: from localhost ([2620:10d:c092:180::1:1457])
        by smtp.gmail.com with ESMTPSA id l20sm9553983edq.20.2019.04.09.06.25.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 09 Apr 2019 06:25:52 -0700 (PDT)
Date: Tue, 9 Apr 2019 14:25:51 +0100
From: Chris Down <chris@chrisdown.name>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	akpm@linux-foundation.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcontrol: split pgscan into direct and kswapd for
 memcg
Message-ID: <20190409132551.GA1570@chrisdown.name>
References: <1554815623-9353-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1554815623-9353-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hey Yafang,

Yafang Shao writes:
>-	seq_printf(m, "pgscan %lu\n", acc.vmevents[PGSCAN_KSWAPD] +
>-		   acc.vmevents[PGSCAN_DIRECT]);
>+	seq_printf(m, "pgscan_direct %lu\n", acc.vmevents[PGSCAN_DIRECT]);
>+	seq_printf(m, "pgscan_kswapd %lu\n", acc.vmevents[PGSCAN_KSWAPD]);

I don't think we can remove the overall pgscan counter now, we already have 
people relying on it in prod. At least from my perspective, this patch would be 
fine, as long as pgscan was kept.

Thanks,

Chris

