Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02E5BC48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:48:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FBD620828
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:48:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FBD620828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E83F98E0011; Thu, 27 Jun 2019 09:48:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E343C8E0002; Thu, 27 Jun 2019 09:48:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4B408E0011; Thu, 27 Jun 2019 09:48:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id B432A8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:48:08 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t196so2459564qke.0
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:48:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=Q7G4ZxXjONoM0oQjby9QegjJRVb3hJCvSyrBr2BT+/I=;
        b=WeU+QzeCfl/IAeMeGNpKYYfdq5JJtssswoBDT0cYn1rj0Iyc3BDjemimFCno/e2S8y
         jkWRyIz9g7ftLeQMjufYHF2KpGOKOOSB/hh2dTEEtx/2cFHFFvAN0qyQyUnetdeboWm4
         kjyx2M6QAWk5z4t/9/dTxMTomdMmqoR4sMVdao5amDbeYgufe0PAHRX2k4DzbcLw8kKi
         hqDg+ihpjcHmmD/cMeZDtt3fQmri2wj2c6gIPOCAPdJVhlITvX8lOWAhLJKGQbFFS3X2
         HWzEEmZm9GxdfIJdbuG0wvzZRGBU5Ls0SDnsqKpBTHW8PVEFQ9bn11/rL9nWgeFUFMvJ
         dLsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAULLgxOARBwX2HCXGZpfHv8/In8acuF3P25/SSX6G3uF6L77Zbi
	IJm89S31jS5AghUeAfLfUrx15V898PeBmEDaEA8I7tpggnrJeikQRa3+D7coc7uPwwZ9tbavtzd
	Xh2lGifML5UcCw0bTxfLFLewdi23wBJnRkdRwRQyDc1qazSjUKmf0oOQT9i1VQNVHzw==
X-Received: by 2002:ac8:68e:: with SMTP id f14mr3252072qth.366.1561643288457;
        Thu, 27 Jun 2019 06:48:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzujG8MP/mNhrjK6WrTSSHXOlz6nGfjs+uwXBToSUdPiYqytZYRYzA6XN9WliFmW8UwShl4
X-Received: by 2002:ac8:68e:: with SMTP id f14mr3252025qth.366.1561643287815;
        Thu, 27 Jun 2019 06:48:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561643287; cv=none;
        d=google.com; s=arc-20160816;
        b=MFCQ4wfQZS90sMzg5eNbLqg4pMwTrolZDzfftmYftz6i9uegOctm3LrS+CA/7Hwq1d
         4JSFgKd9+wbjXCToVVA7AAL9Duz79le81agEU1GvFLyfGYicLBAqjTcedKN31PKYaaaI
         DL76RIJaVnjCwhD8jNYQCYA5pUYeEj3Y3T/PB6k/fJqDpj2nCELE3H+/mObU+Qz6TTB+
         v+9uA9REgJczx5VoPQHKKCO3+5qVQn0V5rXQ1kb86R2nGUjySXW6UBCzWzUpPzfKHLj4
         CJynjFEgkkQpkEqsrN/f7Z1sDTHknTJGFWupdSb778N3/sLV2NqUQHg/sTzXH6I/Dfxb
         EHvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=Q7G4ZxXjONoM0oQjby9QegjJRVb3hJCvSyrBr2BT+/I=;
        b=vg+zHApnUFwo8bg3EsQBNRBXileQCio2d5aTSTOIOHypNmfpQ/fVAa5aFmFp5MRUL/
         66HYNp6cX1/THZ4j+zExlI8CUqSUk46+JOhD9+9Nmz43LEvAaZopy4VJoBGc0kFMijt6
         BVevW36kEza35qhIQ0Q4KDxiiajQ77aKRCmjwa7wPdaTBxlny+bFaBi+KOIZ/DVX3GAr
         XrLgYLYpBgYT508ptj0ClJGX8A4JY3AVn9XgbgqDPa/Pmfb3BrU3PBjEam2wXUCENwMx
         70A1uv6CdrToiIVAa7nIqEW709rgONkL4U+rb3JVSY5MlyJfdXPDzv3mqXcyrGdtC96K
         Z4+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d124si1696388qkb.151.2019.06.27.06.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 06:48:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 34860883BA;
	Thu, 27 Jun 2019 13:47:46 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BE13B5D707;
	Thu, 27 Jun 2019 13:47:40 +0000 (UTC)
Subject: Re: [PATCH] memcg: Add kmem.slabinfo to v2 for debugging purpose
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>,
 linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org,
 Shakeel Butt <shakeelb@google.com>
References: <20190626165614.18586-1-longman@redhat.com>
 <20190626152553.6f9178a0361e699a5d53e360@linux-foundation.org>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <78c5ba55-b755-1997-edcc-9ee03a3f3300@redhat.com>
Date: Thu, 27 Jun 2019 09:47:40 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190626152553.6f9178a0361e699a5d53e360@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 27 Jun 2019 13:47:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/26/19 6:25 PM, Andrew Morton wrote:
> On Wed, 26 Jun 2019 12:56:14 -0400 Waiman Long <longman@redhat.com> wrote:
>
>> With memory cgroup v1, there is a kmem.slabinfo file that can be
>> used to view what slabs are allocated to the memory cgroup. There
>> is currently no such equivalent in memory cgroup v2. This file can
>> be useful for debugging purpose.
>>
>> This patch adds an equivalent kmem.slabinfo to v2 with the caveat that
>> this file will only show up as ".__DEBUG__.memory.kmem.slabinfo" when the
>> "cgroup_debug" parameter is specified in the kernel boot command line.
>> This is to avoid cluttering the cgroup v2 interface with files that
>> are seldom used by end users.
>>
>> ...
>>
>> mm/memcontrol.c | 16 ++++++++++++++++
>> 1 file changed, 16 insertions(+)
> A change to the kernel's user interface triggers a change to the
> kernel's user interface documentation.  This should be automatic by
> now :(
>
>
We don't usually document debugging only files as they are subject to
change with no stability guarantee. That is the point of marking it for
debugging instead of a regular file that we need to support forever.

Cheers,
Longman

