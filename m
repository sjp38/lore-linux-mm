Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEE3CC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 16:10:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 991E321882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 16:10:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="AZ1omCiJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 991E321882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 340E68E0005; Wed,  3 Jul 2019 12:10:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F1868E0001; Wed,  3 Jul 2019 12:10:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E04B8E0005; Wed,  3 Jul 2019 12:10:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id F235C8E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 12:10:32 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id y19so3336314qtm.0
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 09:10:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=wRhFAPDN9W31/7q1dT/zdEt3Cu7N780+Gi6e7xOeZoI=;
        b=LZHFDi49HC/e24SIiQgcecihht5WZyP/vnGd6gqhuCiLNJQiVrfhLynxG9L+MWmzO0
         8R5tdBevmBEMQPnVHUS8IHDXfUO+0pw0Bz8scpH15KJiP4FGTNfUv0P6Fjdw2wcZuz2o
         y6iUWDqL8t5vhIKWgIngyQuDEeQyGvt3y8SzjIHNEGCJ2SwqQUxPda/Z1MTnB6qmvfZj
         wKKFhHwWcUFZGUaHogH4YLa4myDnetEq98NOGhN8ffvG6Nf1GG/Rx4eQgKzQV8pYUOj5
         vi0LGDGeYiBFDCQ3iO21U00oQ0BYFua36rhwvISIz/sp3iI2NlZELFiKHCzVCpci9aZ7
         b1ew==
X-Gm-Message-State: APjAAAXMmhFP+2G4zzci33e8Ulyzd8RRUl4DCoKu0vz8pGGE/YuOdBzS
	bCfn7Xl5xk4WHay1FF9zyYeMv3d4uhZzy67giKZo0tfh7QFMGBLC/Nh6vnoUkocKBPIcyU1Jc6+
	KIxWOQ5OYXMilQ10Po+cxiRXUOX5Lk3D0Z4s7SmhRUZboGHBBq3coqNpLY6St9Uo=
X-Received: by 2002:ac8:219d:: with SMTP id 29mr30967971qty.37.1562170232743;
        Wed, 03 Jul 2019 09:10:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLSWY6fZwqiF8I2EH0Y4lTCJPZT+gG0tBrJbISNVF87+unr4FhucUNdmBQp/VI4uLvIfDL
X-Received: by 2002:ac8:219d:: with SMTP id 29mr30967920qty.37.1562170232080;
        Wed, 03 Jul 2019 09:10:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562170232; cv=none;
        d=google.com; s=arc-20160816;
        b=ZLfxeG7/Mw2HSedZB0fXO8mopd4/AAEkZmKlbvVIQA2pzZmILG1zI3yor/vXXVBLTV
         45b5MSo8u0qU3iwwsaONwrwRR5WhA3mWEgntiiCoI/3zgRoy0hDbOtGNSHOsxscbh3GP
         ph2RlolauaTiuUYAoU5gVRCfAdv0AjYIgKszmKWkEmMh3P3KRDNM9D+kDKb8Kdc2u58E
         wSXZd7ccNeGnRhqfsZh9VBgobAZK6TuzlI8hQMyS/UjHOaUc+KNCtfbFrhKCJUHKLrpx
         0yOpXvxcrYUWQOK3Fm3K/uyn5N7eyzWqhQrEweUpLRdYLsUQmqnvQBMpMcdmhY0iPrBj
         g7hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=wRhFAPDN9W31/7q1dT/zdEt3Cu7N780+Gi6e7xOeZoI=;
        b=WPCyO4J/VW0uE9Eka0GudvoCN8hKoFLSVhAvjKSuxPypUD2Mcv5TB3N2jNaB6M1FmE
         5cbE51QO3uorVKxZZuCI+eRqe83EmsKh8LA01Il0MpCwQ1kTWhNhBuI/EGbHvdHaUU38
         Sdu8skgitr1YTtEJYfsXHEyqY/BEAJp4s1geHCihUTHRGQBbi0A5Lis8+4AEjfZUK7PE
         Px4cZ/j6Svv4Rsxwpsnz4uN5quhrFLnAZhzEML8aEDomV60EnrQ2AOO9rD7GZyAQ1aok
         rhWlCMp5/xA47XYkevhi4r4wruNaI1zH/47R2znaCuoEWTUQSdkE4YGh9jO6XGluoPsM
         1Kjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=AZ1omCiJ;
       spf=pass (google.com: domain of 0100016bb89a0a6e-99d54043-4934-420f-9de0-1f71a8f943a3-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=0100016bb89a0a6e-99d54043-4934-420f-9de0-1f71a8f943a3-000000@amazonses.com
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id u63si2323949qkc.266.2019.07.03.09.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Jul 2019 09:10:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016bb89a0a6e-99d54043-4934-420f-9de0-1f71a8f943a3-000000@amazonses.com designates 54.240.9.34 as permitted sender) client-ip=54.240.9.34;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=AZ1omCiJ;
       spf=pass (google.com: domain of 0100016bb89a0a6e-99d54043-4934-420f-9de0-1f71a8f943a3-000000@amazonses.com designates 54.240.9.34 as permitted sender) smtp.mailfrom=0100016bb89a0a6e-99d54043-4934-420f-9de0-1f71a8f943a3-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1562170231;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=wRhFAPDN9W31/7q1dT/zdEt3Cu7N780+Gi6e7xOeZoI=;
	b=AZ1omCiJcuo1xOM8hwRxHYsOmsp7QmftZ/s2l9pRNQ0/UpulCa0XIDjkDIJhXeHD
	pEGlkzc0c6EGKQ3xgeTyAVXNbkiyJdKJTl1et6y1CcBPnwLyUJdn1wOHCPxXaEx/N20
	SGvnPPNX4Ry6+ie176GFa9Q7j5m6Rn7y0m3ld11U=
Date: Wed, 3 Jul 2019 16:10:31 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Waiman Long <longman@redhat.com>
cc: Michal Hocko <mhocko@kernel.org>, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, 
    Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, 
    Johannes Weiner <hannes@cmpxchg.org>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, 
    linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
    cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
    Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>, 
    Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
In-Reply-To: <9ade5859-b937-c1ac-9881-2289d734441d@redhat.com>
Message-ID: <0100016bb89a0a6e-99d54043-4934-420f-9de0-1f71a8f943a3-000000@email.amazonses.com>
References: <20190702183730.14461-1-longman@redhat.com> <20190703065628.GK978@dhcp22.suse.cz> <9ade5859-b937-c1ac-9881-2289d734441d@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.07.03-54.240.9.34
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jul 2019, Waiman Long wrote:

> On 7/3/19 2:56 AM, Michal Hocko wrote:
> > On Tue 02-07-19 14:37:30, Waiman Long wrote:
> >> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> >> file to shrink the slab by flushing all the per-cpu slabs and free
> >> slabs in partial lists. This applies only to the root caches, though.
> >>
> >> Extends this capability by shrinking all the child memcg caches and
> >> the root cache when a value of '2' is written to the shrink sysfs file.
> > Why do we need a new value for this functionality? I would tend to think
> > that skipping memcg caches is a bug/incomplete implementation. Or is it
> > a deliberate decision to cover root caches only?
>
> It is just that I don't want to change the existing behavior of the
> current code. It will definitely take longer to shrink both the root
> cache and the memcg caches. If we all agree that the only sensible
> operation is to shrink root cache and the memcg caches together. I am
> fine just adding memcg shrink without changing the sysfs interface
> definition and be done with it.

I think its best and consistent behavior to shrink all memcg caches
with the root cache. This looks like an oversight and thus a bugfix.

