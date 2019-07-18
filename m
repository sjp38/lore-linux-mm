Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63390C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:38:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05B9F217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:38:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="m9aJEqB6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05B9F217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 977B56B000C; Thu, 18 Jul 2019 07:38:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9274C6B000D; Thu, 18 Jul 2019 07:38:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83CDF6B000E; Thu, 18 Jul 2019 07:38:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC8B6B000C
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:38:12 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id r200so22955647qke.19
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:38:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=5h7nc3ShpN2HZMYYeZJQM9eacq48yLOThoJ1TPGlT9U=;
        b=N4HqNcc9AVI4+wI2H8VjuUEe0aceQ6seGRu8a/nuMSII8lSJ80SLkOihWGY4KVWTKK
         5OYyXU3BdcilA/9VN1ESmnTI1xAGdIEuL6/NvAau7+gi222Fo8dhNUpfrh5CNvLLqB5C
         kOXtxK5pYoQMpDWRUc0CMN4wNJHTh8NhwyAf6UqD7YdvHESg1NmvIf/2f7rKUuk66PH+
         epn0KqwcR3fsKMPTAvos5skFr9kMnPrZHY9kj2eppSMsguRSjNFMmBaBg2a+23tqOSSz
         4qMX2WQ6Kmca6UiPMJgzTPr3RBr1fPUvcQDiFZTfpcizaPBeQaWyGh3qF0peT7ppk4RK
         QkVg==
X-Gm-Message-State: APjAAAXqpudKuaRnwc0eY18/lUFjzoYN+GQchYA/YEuA07rQff8gTUJt
	Y/+U+F3nvclydOGAElR4pse4NzEAdUvTiPML4Hf/5lYICghORbEW0HyQsEaPpQ9QVs5b4ybjtfh
	U+IAtbBr0BhyDQOySbPjkWnrFuToe9eIHXECWBTBJGcCKBddc8VgWugncuoM5XSY=
X-Received: by 2002:aed:24d9:: with SMTP id u25mr32169039qtc.111.1563449892160;
        Thu, 18 Jul 2019 04:38:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzs6WS8A9tjl9L3pZ+/fW8QbgsXVduXkJgXsG0aj7TgJrwT/OI4MQrDQqu9S/UpVgBCNUDo
X-Received: by 2002:aed:24d9:: with SMTP id u25mr32169003qtc.111.1563449891627;
        Thu, 18 Jul 2019 04:38:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563449891; cv=none;
        d=google.com; s=arc-20160816;
        b=MMIrruh9R581/qLwfWJmbNGJjUFOo3NoGzplTa+A1X020UR+xcf3faZ1TDLNg5nlwv
         +MN/ewreN7E3+NZeI5NMErRQm/pP2sYchaRTm2OJOD2rdpyMaqD/qF1SfIYP+NYcADFI
         S2MNya1guzDFRdmelKmd5mOz5OCGYb0xYbucMB5+RDx87yeB55wOtBP9J9A2WnPfBszm
         OegmzCkXxmD85d2HmB9NXAxZIrI6coTK1hAHkhIi5cXtRQCiySSFlq+syfHkemWg98SE
         52tA55WHDz4yq5kQ0YMfX7c9n9JSYNkFcoCkBPYuw4ih5SwMrfTidWg4GVpb8uO+Saat
         JE2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=5h7nc3ShpN2HZMYYeZJQM9eacq48yLOThoJ1TPGlT9U=;
        b=mtcMfaAvqvx3q2mOcn5ITcxNF0uzcV/d6nEWqMN39ZJ8AN1aJYaVSi89cTLfeDD+BY
         jR1JKj5c3jzeNLrY7V3iWzFuhNg/+yj+WspiHoaFle8fr/lwI7FIev+gzixE49m1H/Vh
         N69WUIh3N34qZtTLKWpzlQ7uElp8yw2Uv2+m6ynaIB0x9bobpAwYCyvIHYKuMFRW4uO8
         ysNBA5PnrryiatdZLSRepLkFKmoJMxYLIf7czssIe+mq9sEDAsD8bClQFxQ2dvSHISyX
         HDDAPa2+8UQOLUMO8y1Q9Zc/E60JDtxJsGycbPQgluB3VX4UnznC/W0hCFAjmpFTFEJU
         wACw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=m9aJEqB6;
       spf=pass (google.com: domain of 0100016c04e0192f-299df02d-a35f-46db-9833-37ba7a01f5f0-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=0100016c04e0192f-299df02d-a35f-46db-9833-37ba7a01f5f0-000000@amazonses.com
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id 17si19681994qvp.87.2019.07.18.04.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jul 2019 04:38:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016c04e0192f-299df02d-a35f-46db-9833-37ba7a01f5f0-000000@amazonses.com designates 54.240.9.31 as permitted sender) client-ip=54.240.9.31;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=m9aJEqB6;
       spf=pass (google.com: domain of 0100016c04e0192f-299df02d-a35f-46db-9833-37ba7a01f5f0-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=0100016c04e0192f-299df02d-a35f-46db-9833-37ba7a01f5f0-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1563449891;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=xWVA8lsMEzKAdMagd2kfoiEHBMGzewwRgNqmEIy/2Rw=;
	b=m9aJEqB6b/1X8K3XpFwzGXp3UjJognrWDaP+nhgc5YMHZPUQ+jV84Zilt5nBS0t8
	zn0b1O7AYnfXJvggzlsCa4XZ+C22Gj2jzs90cUpCPwdPcSeeznIrScvUIUt5uO5Jxk3
	whHhZdArsxSZAJUEkRzOim1yrj1Y0H/kKp1TBUPI=
Date: Thu, 18 Jul 2019 11:38:11 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Waiman Long <longman@redhat.com>
cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, 
    Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
    Shakeel Butt <shakeelb@google.com>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 1/2] mm, slab: Extend slab/shrink to shrink all memcg
 caches
In-Reply-To: <20190717202413.13237-2-longman@redhat.com>
Message-ID: <0100016c04e0192f-299df02d-a35f-46db-9833-37ba7a01f5f0-000000@email.amazonses.com>
References: <20190717202413.13237-1-longman@redhat.com> <20190717202413.13237-2-longman@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.07.18-54.240.9.31
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jul 2019, Waiman Long wrote:

> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> file to shrink the slab by flushing out all the per-cpu slabs and free
> slabs in partial lists. This can be useful to squeeze out a bit more memory
> under extreme condition as well as making the active object counts in
> /proc/slabinfo more accurate.

Acked-by: Christoph Lameter <cl@linux.com>

>  # grep task_struct /proc/slabinfo
>  task_struct        53137  53192   4288   61    4 : tunables    0    0
>  0 : slabdata    872    872      0
>  # grep "^S[lRU]" /proc/meminfo
>  Slab:            3936832 kB
>  SReclaimable:     399104 kB
>  SUnreclaim:      3537728 kB
>
> After shrinking slabs:
>
>  # grep "^S[lRU]" /proc/meminfo
>  Slab:            1356288 kB
>  SReclaimable:     263296 kB
>  SUnreclaim:      1092992 kB

Well another indicator that it may not be a good decision to replicate the
whole set of slabs for each memcg. Migrate the memcg ownership into the
objects may allow the use of the same slab cache. In particular together
with the slab migration patches this may be a viable way to reduce memory
consumption.

