Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A51CC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:52:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E958820656
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:52:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E958820656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75B926B0003; Mon, 29 Apr 2019 10:52:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 708D86B0005; Mon, 29 Apr 2019 10:52:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F8476B0007; Mon, 29 Apr 2019 10:52:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9636B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:52:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o8so4951669edh.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:52:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kLPZzCYSU14EqNb9B4IyV/WojzZ+JJh3PDwuHswvpRQ=;
        b=g6PWCPMvBukGabIc/UqXmcnsNVx718iSSNm+wO2u+yvhmhwfAE1HCe3uj86rJzVUQv
         aVXZcpNoaASIMRgHzclHD7R0XB9LOjrEqhZ2uU6sul5FuN9dhWgNCeA8f1d7gFRS7cdv
         RM0ALbTHzNDvjnZHyI+xpMd4BMh09SV1C+P1r/DF/FqhEcL8dkPNAjc2sk0/K0jk0KN3
         wBTCdNP1GJ4nfZqp6Ypy1N6VD/MHTHLsYT8prLvH7pldAG8tS1cBKBCxbuj82cHsOsJ9
         XXaoCp4z0p4Ub+nxA53N7Mii58xSZ2yquXeHeglpw0XXOp83TAQjYA/z+nHvz+lBRxkz
         0GQg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVaVZZVYhq9CsIibg3k87roHb6D1uxzdms3ICArkq8r+F0k6U7Z
	L9JQWIwl4g7Xr8EixbR167VIMhp9YHpCzB3E6FfQD0BrTlX9WySoJJGM8ofJe1JhhgbPwqBicKB
	pdBTGMW3Rpv0DPoQKA4yOQXP/UkLqBKSsks5/O24djX5Svi++hS5I+YvtYmyP4DI=
X-Received: by 2002:a17:906:5241:: with SMTP id y1mr7103418ejm.8.1556549574627;
        Mon, 29 Apr 2019 07:52:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+okdBoyVbtpWYMPr5dK0BBDlxU73tDHP3bKqEqNz1keaXANKCq83WdS6PDk4wF9oIclHR
X-Received: by 2002:a17:906:5241:: with SMTP id y1mr7103382ejm.8.1556549573562;
        Mon, 29 Apr 2019 07:52:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556549573; cv=none;
        d=google.com; s=arc-20160816;
        b=jBSJmlY10nkC9AdX2XBlfJ9Sw6f19Bn1oLhU6Z0La4MLSlMgaiO8PVnaRI/LtqgvHC
         x2xA7atIURBFdx4D5SWvnyMibMwVCsnBcsrc9TN4LRhkfnoEqwt8T/DxnrI/dEO1m1PJ
         Ujfms8QorgQiqb5vWXtoj1ypfxGD7O0T4xKeCveP8juNg+JFa2fuhNoAYUklE3XXgl91
         MAOtu/cO4wmkLIF6weulQmqJ370hHH95yAWRcNV6o/afqr8WdfJ63IWWb7GwUSCBKYpb
         3Y3wAiafZPsRIZ0rtb1TlO5PGKKupkMUmwHjzZM8FL9xtLA3wqj2vwmjTWu2Lf48ydrF
         Jvbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kLPZzCYSU14EqNb9B4IyV/WojzZ+JJh3PDwuHswvpRQ=;
        b=oNopYb4wGH1rYl/tnfjknTVKDNWD1J5o9F2MdkYmqbVH4DroukvR7B2cFdoD2ZJ5un
         088MZUTczseWcEicII/rCuv9oNxEIGfpy2ksoTwEZp7YBJpIu/3Tqarj0Fb28eFqW4pl
         aF5CjYxMR6gy0vL1LS8I6nhTSkt+k4il9Xr+uaQmNcYMXmCx4FnL4/vRWHxWRYEXr5SD
         Bh8C1f93A/PPE+9gm0v8YsWWrbIVcNlTPmZIl5FZkX0w+nul4so8qG276ht0sU2JDpRN
         TEjEiToDRoJTgIKvv0HXgsRTu3IzDR9NyfUUtS/S31ou7sDPImY2TuW0EBb4q1Hg3li7
         wGow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e19si949259eje.133.2019.04.29.07.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 07:52:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B56CAAF61;
	Mon, 29 Apr 2019 14:52:52 +0000 (UTC)
Date: Mon, 29 Apr 2019 10:52:49 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>,
	Cgroups <cgroups@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] memcg, oom: no oom-kill for __GFP_RETRY_MAYFAIL
Message-ID: <20190429145249.GN21837@dhcp22.suse.cz>
References: <20190428235613.166330-1-shakeelb@google.com>
 <20190429122214.GK21837@dhcp22.suse.cz>
 <CALvZod6-EOAkcuiuBpoE6uR2DFNUkUY8syHxenFEAZTxhgNMhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6-EOAkcuiuBpoE6uR2DFNUkUY8syHxenFEAZTxhgNMhQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-04-19 07:37:08, Shakeel Butt wrote:
> On Mon, Apr 29, 2019 at 5:22 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Sun 28-04-19 16:56:13, Shakeel Butt wrote:
> > > The documentation of __GFP_RETRY_MAYFAIL clearly mentioned that the
> > > OOM killer will not be triggered and indeed the page alloc does not
> > > invoke OOM killer for such allocations. However we do trigger memcg
> > > OOM killer for __GFP_RETRY_MAYFAIL. Fix that.
> >
> > An example of __GFP_RETRY_MAYFAIL memcg OOM report would be nice. I
> > thought we haven't been using that flag for memcg allocations yet.
> > But this is definitely good to have addressed.
> 
> Actually I am planning to use it for memcg allocations (specifically
> fsnotify allocations).

OK, then articulate it in the changelog please.

> > > Signed-off-by: Shakeel Butt <shakeelb@google.com>
> >
> > Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

