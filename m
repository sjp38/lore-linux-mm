Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A81DAC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:33:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 705692084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:33:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 705692084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02A736B0005; Wed, 15 May 2019 04:33:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1C8F6B0006; Wed, 15 May 2019 04:33:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0C006B0007; Wed, 15 May 2019 04:33:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 913656B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:33:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5so2768212edz.3
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:33:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=w/mCSJ42tMOjHxwrKiZFswluDHd9J+p4R9eSNk8N1rA=;
        b=IAgE02KfngkJn7+9m3k7L9f64NDU2sJUAsOnwLMyL0q7K1UyBHR2EYSyp7UfIz2o4l
         YfgIvP3dtxZVaKiEF0aTmLhbBsqllerFXvCEJnzm0r7CT8hkF9UAzFqPJw5WKqJf0TvV
         34s0sKc7LuhJ9jjLAx7QGpyf2pQYndo3IsTlfXPLOZPcXYRZ+LKsUyI4hYC5bqlvQTjN
         B0o8JHx8mL3CvHhEM7ag7CiX9+CsJZuRF/cTrDRSKzC3VFp9eI6rdKJYQnZS7Xsx3k+j
         cai0Tl8F5WYjFKc01AO+fPYZUbcgV1j1NaCDF0Z+i/3EdKZhZuRx5LATaJB+w0rfeglp
         JmQw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXbgYVWVcxGYILzinP5btnNFoQS6u/9bWVkkTbny6GTuFQOMopp
	9hpmvuXu7jG5oz48OjxijMvvRcUOd42suwRcMuhRSc/2st4APUolg6yrzkld5gi3ZlZ8epEl5CX
	m9DoVC1xuyjSUsCbwlnzXnrvMa7bAs/ZIjdV3U+wY1lPV4GotZQKb59QSpWUiUak=
X-Received: by 2002:a17:906:2e58:: with SMTP id r24mr8144721eji.184.1557909204148;
        Wed, 15 May 2019 01:33:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3a6BH76aF7MNr/WLGxddYIsQ15cV50ZyEhKIJB7z+rPs8TbeaubzbuaMzPVxk7NP8O3G1
X-Received: by 2002:a17:906:2e58:: with SMTP id r24mr8144677eji.184.1557909203290;
        Wed, 15 May 2019 01:33:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909203; cv=none;
        d=google.com; s=arc-20160816;
        b=wTosqw6JtYNbkuqJ4IYDOjc80mzDyURdExfDN+4OUdSDqqQn1Qxjiquvetlwrt8Gxi
         BIwyIRZCtRXQ/soJMXn4zh/MmZBi1tgYsRH39Ds1BGxwYdcvewuM61I9LTDXY5zQd9Em
         9R7MsSAFYr+XXnQSVPr9qZR4jIB9XdSKvVJAK80d1/bpF2xrAtlwkDpDOml5713Cu0s5
         D2+WkAuoBaoXd25cKMt5fK+L9N4exApc0g4tjbLnI5gh487gBA34d/9jiud94CJPydpA
         lo6AILbdEsiPF+5FgRak3tDqJJTLOeCXQvwnGcdG/ByRD1OU11CCApMLEZZYHg4zZxlR
         dShw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=w/mCSJ42tMOjHxwrKiZFswluDHd9J+p4R9eSNk8N1rA=;
        b=oQQ7esdq9ch12Sexg54vyoIUUxyxTMG2fRzyB8Tcd+4WRKjFFk3zAYvY0AWWQ+UKKf
         WqYYyhhiyc+GMzyOzdm0vxHbmgm6ho+7kuFF4mLZ6mGh9Y4U39w6i6Xltc2egUQDQQCW
         f+1myN5CFHpIgTPb36RpUfrywoo0P2yGX5yTjT6ljkXvS0AxjW4LFxC7C+d/Ak0Y17nc
         ZLHbtmt1v4u8tMndMkG1pB8XLJly9+7WGxQCfois0yhOR4IWK7F2/hECyYEi1nJLam9L
         8siLH6zPYGkJXrkC9+ZVthL8xmZhI5GfFVVZzaq+FPkg49ZMddZ8DmKCF6gGhxrfLun9
         HiSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i26si944905ejc.361.2019.05.15.01.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 01:33:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 92802AFA7;
	Wed, 15 May 2019 08:33:22 +0000 (UTC)
Date: Wed, 15 May 2019 10:33:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190515083321.GC16651@dhcp22.suse.cz>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
 <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
 <20190515065311.GB16651@dhcp22.suse.cz>
 <20190515073723.wbr522cpyjfelfav@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515073723.wbr522cpyjfelfav@butterfly.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 15-05-19 09:37:23, Oleksandr Natalenko wrote:
[...]
> > This is way too generic. Please provide something more specific. Ideally
> > with numbers. Why those usecases cannot use an existing interfaces.
> > Remember you are trying to add a new user interface which we will have
> > to maintain for ever.
> 
> For my current setup with 2 Firefox instances I get 100 to 200 MiB saved
> for the second instance depending on the amount of tabs.

What does prevent Firefox (an opensource project) to be updated to use
the explicit merging?

[...]

> Answering your question regarding using existing interfaces, since
> there's only one, madvise(2), this requires modifying all the
> applications one wants to de-duplicate. In case of containers with
> arbitrary content or in case of binary-only apps this is pretty hard if
> not impossible to do properly.

OK, this makes more sense. Please note that there are other people who
would like to see certain madvise operations to be done on a remote
process - e.g. to allow external memory management (Android would like
to control memory aging so something like MADV_DONTNEED without loosing
content and more probably) and potentially other madvise operations.
Or maybe we need a completely new interface other than madvise.

In general, having a more generic API that would cover more usecases is
definitely much more preferable than one ad-hoc API that handles a very
specific usecase. So please try to think about a more generic
-- 
Michal Hocko
SUSE Labs

