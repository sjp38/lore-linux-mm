Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B58F4C282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:09:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F68420989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:09:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F68420989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C68D8E0002; Wed, 30 Jan 2019 04:09:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14E6E8E0001; Wed, 30 Jan 2019 04:09:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F30A78E0002; Wed, 30 Jan 2019 04:09:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 934188E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:09:49 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c3so9244951eda.3
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:09:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2YT4l9j8c3qE4ESQ9uCNzQzeTA3r/3UfWiab/Pt+/FM=;
        b=AIZ1fwE9ThMos+Y032U2rpDcLMMGRw320xMhJvt2yvcpXdX5WwascEKmvOfd6h1spV
         OUkCV/jcC1t7QPovM4NF6hzMMw9cn6AFoz1FauxSFbwk+gcNIyeKJmQNQADUiKhcSoAC
         Hrww9yZXocuZtdxDV9nRJftHkgLd5GJpr2/FEmdLThWW4HCBNGyAmYSBgskY4l5FoOwk
         G+lXidv5ygftFeaka9jj2dnF4t/Ds4bhprHABC/ZPErCBQW2Q6HDIT/7538aeBrBBX/p
         0UK7UaxSBiozIOBVlgzkffRX/vtzLXINNPG2DKdzjyXHSaYQAEmG7P7XbK4fE3fBDzg2
         3WTg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukfbPhohMLs2bhIbvPvG1D5FK3PgP34Ho+WnReNSPfXWI2TjAIRM
	WqD7XK7bpqq5azKthl7Z9E7gjU56e/rLINGyTbK1/R+ye1mfcr0Rr6BOB/gVwahc+gAs3r/JjJK
	ANNEqCp937kxbc9c+pZIg3N+xEPFfnEtPS+wkq5gY9bb026bBzqZgy83EPl6uYIA=
X-Received: by 2002:a17:906:7c42:: with SMTP id g2mr25992702ejp.212.1548839389143;
        Wed, 30 Jan 2019 01:09:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6HnkuVyXNU2Ut3t8M9wUNEiIbGiwJw3q2ELTiLENbimAB4HD6JOSUxvI/GtD32Gkdi8NZj
X-Received: by 2002:a17:906:7c42:: with SMTP id g2mr25992659ejp.212.1548839388301;
        Wed, 30 Jan 2019 01:09:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548839388; cv=none;
        d=google.com; s=arc-20160816;
        b=DGmLkIvco6k76ODTHxzMwWIrJ9YWaxDfqrtWmqlz9pJP6EpaiftfXdTB0/UVyHizWS
         h8/R0rNqaYhl9CAvUIfGj8+5jCdueb5O30ttiLD6fMXXObmYYAb41/xorljdR0jZ1jdn
         j/+YVCXebzfrTvV5S7WYFBzK5kwEIDsbyOivHbl2ThweokGz8QK50fnwI3J4B2Dsu+hU
         dKNaudRp57DUIEab1U32txwspPxHQ9FzeU7E6E4Ii9Uq6pKJTXjYWXHmcp8+gWfMhE3Z
         tR1g4E0Pyb+CH8yk5PHkNLP0UFRVIgvuPpJN+eu31IA6UIhqEDd9ppkScHJwZaeKp+bS
         3ADg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2YT4l9j8c3qE4ESQ9uCNzQzeTA3r/3UfWiab/Pt+/FM=;
        b=pX7ZzhPOzv3zUdSbchqTvfuEPmVxK2fQfpIxOhQc1x30C4G07S0rzUEC4aBpyCy4dr
         Nfnv3G2jJeEdzDy7scpE98I9d1qc+9ooKI6SOe36O+RbMPth3yvDzIg6pGmtBvw25N+W
         4ArQImQc97dHAQEQtKGWX+jEnjIXZ+6Pn7mtaYK0s6Rkxjl/fRl8cUQ5cPtMPXbbWZRc
         y5PiYJpO3S3yY42X8ZlEGORZqknahS9rqygZ3ivStcsq12E+a9dSNlmiAiSa6mYfN1UE
         G/cAo7lr2/2cgYbyYa948sNv2SXfc0VcC+p2ZFfEwdSJSvloi0O7euhae92FYnh+TYat
         xoog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25si653124edu.428.2019.01.30.01.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 01:09:48 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4118FAD73;
	Wed, 30 Jan 2019 09:09:47 +0000 (UTC)
Date: Wed, 30 Jan 2019 10:09:45 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Linux-MM <linux-mm@kvack.org>,
	kernel list <linux-kernel@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190130090945.GS18811@dhcp22.suse.cz>
References: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm>
 <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
 <20190124002455.GA23181@nautica>
 <20190124124501.GA18012@nautica>
 <nycvar.YFH.7.76.1901241523500.6626@cbobk.fhfr.pm>
 <nycvar.YFH.7.76.1901272335040.6626@cbobk.fhfr.pm>
 <20190128000547.GA25155@nautica>
 <nycvar.YFH.7.76.1901300050550.6626@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1901300050550.6626@cbobk.fhfr.pm>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 00:52:02, Jiri Kosina wrote:
> On Mon, 28 Jan 2019, Dominique Martinet wrote:
> 
> > > So, any objections to aproaching it this way?
> > 
> > I'm not sure why I'm the main recipient of that mail but answering
> > because I am -- let's get these patches in through the regular -mm tree
> > though
> 
> *prod to mm maintainers* (at least for an opinion)

Could you repost those patches please? The thread is long and it is not
really clear what is the most up-to-date state of patches (at least to
me).
-- 
Michal Hocko
SUSE Labs

