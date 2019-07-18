Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 907F5C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 18:04:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EC7420873
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 18:04:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EC7420873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A26B66B0005; Thu, 18 Jul 2019 14:04:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AFB56B0006; Thu, 18 Jul 2019 14:04:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 875D98E0001; Thu, 18 Jul 2019 14:04:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 630956B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:04:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id m25so25034337qtn.18
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:04:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=60hgcSP5ZBMYc8BGYqz2qVFtxH2uomSyM2xS+2okEPE=;
        b=LloBSxkdPyxdTumtPUzt2q+8zehRrQ76EiSE783FtmRIvBW5edp6be8+UZBtAumVrd
         6U8dh08IFgx86HJt1A4lJxlQ9j2SmASqosr1RfQXMhsfcRE64KGoYtOyEBbl3+VNWxLS
         4iCU3kmvcdFE19Qhkiws9SpqRZGyEKx5QV17ayBVh9N8vJsijdZpDfWao0yVK0dQzktk
         /wgr9VdiUnohwc/2N3UvMtKzshsBxdAccO0W8vQyl/7H7Vve+2w2bbBNMPx7cVmck60f
         SbdoyGWdb+nyTyX0N2hfZTcnU4yTW2KM1txx4JyhZAoCZ8GhSTRm2ItReCGdYSSGCrLb
         ynkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVHo5M3NMoA4WzehDtdiOVZeNivDnGSYVQdgfObhM3SLnJJPEJm
	ALOAGXohcxt5rgX1dbzPfCD+RHeGpspMCXLe96/Ldgr0u+skPMKqs4Nk398x4JTqvqGrbXDmw9J
	Zn75IxIUl++mecSjYrhJ9dSd964HTcxx8XgRtNAaLYz5tSzY7BTz3ozkNTRLbKTykZQ==
X-Received: by 2002:ac8:7104:: with SMTP id z4mr33185548qto.52.1563473082155;
        Thu, 18 Jul 2019 11:04:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5tSWtEXE2n4hULF3jQp33QafunyccuoK1wO+zSQ9skm+LKBTJ7KziTwM/3AkGWVy4P/vd
X-Received: by 2002:ac8:7104:: with SMTP id z4mr33185491qto.52.1563473081337;
        Thu, 18 Jul 2019 11:04:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563473081; cv=none;
        d=google.com; s=arc-20160816;
        b=xO9cZPNHuWNrB6NmWwMV7BnBTAsDG+fDzRrhQJLWKi/QgZfSFZoxzLdOdwmMRxKiwH
         r+sUAqWYnKC0SnEJOd5u8O3D+ixbhlTFya0e/38u7VKtOpV71oDfILjgUpPfq5j2SYBd
         31qzWY9fYNu7I/G48qHjkMcGPApi72Xje9XyieMpeNIc4Pbtoxc/epY1kkCWoiugfLn+
         JQyMv/DkWGeT3D20m45aqtRoDwb3y9rHh0kDX5HIFBiMWDidAbs2MzfZ/nTiM2juTqCG
         u2fOhHENOzY6A1ystvoPecsVwTSz3qQ6HiaX81nxaG0Wep7hsDQACgKcFGFdBVAiSZa5
         4sdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:references:cc:to:from
         :subject;
        bh=60hgcSP5ZBMYc8BGYqz2qVFtxH2uomSyM2xS+2okEPE=;
        b=ew4eNZTot/Jd+lr0VGcYFvXzRUHrLbzYFKaiOOrl4bToSbxdaQql3Mwyaat/DH0qFU
         PXubkgFH8FHsfg4pZDOSeXS5wJUwkMU1lBSuOa3/e9+Hhzdh2WXs5OGFhD26w972bTW8
         VDvcS1tpRM+NYJmqBtrsJJJzX5HYWmH5ppiczXkvFkYxj84XGwy1u/WhsNGIJlGhD2lq
         8VxeYAIhdhH6aLEaCT0WZMKdFAGgsST8AARaMTsQESqp8zttos8mcRhoZRmdQZBQmdzD
         LRSlrQw425pqJEPIWJn6gXUM0rdJYSNI408A1Ip5YWtY939jis+4lEaIg1FDjFSEVIUb
         QR9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b7si17735376qtg.142.2019.07.18.11.04.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 11:04:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 875EA2BFCA;
	Thu, 18 Jul 2019 18:04:39 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 679025D71A;
	Thu, 18 Jul 2019 18:04:34 +0000 (UTC)
Subject: Re: [PATCH v2 2/2] mm, slab: Show last shrink time in us when
 slab/shrink is read
From: Waiman Long <longman@redhat.com>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
 Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Shakeel Butt <shakeelb@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
References: <20190717202413.13237-1-longman@redhat.com>
 <20190717202413.13237-3-longman@redhat.com>
 <0100016c04e1562a-e516c595-1d46-40df-ab29-da1709277e9a-000000@email.amazonses.com>
 <6fb9f679-02d1-c33f-2d79-4c2eaa45d264@redhat.com>
Organization: Red Hat
Message-ID: <9d35da26-6d85-d879-c966-3577bdb0cf02@redhat.com>
Date: Thu, 18 Jul 2019 14:04:33 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <6fb9f679-02d1-c33f-2d79-4c2eaa45d264@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 18 Jul 2019 18:04:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/18/19 10:36 AM, Waiman Long wrote:
>>> CONFIG_SLUB_DEBUG depends on CONFIG_SYSFS. So the new shrink_us field
>>> is always available to the shrink methods.
>> Aside from minimal systems without CONFIG_SYSFS... Does this build without
>> CONFIG_SYSFS?
> The sysfs code in mm/slub.c is guarded by CONFIG_SLUB_DEBUG which, in
> turn, depends on CONFIG_SYSFS. So if CONFIG_SYSFS is off, the shrink
> sysfs methods will be off as well. I haven't tried doing a minimal
> build. I will certainly try that, but I don't expect any problem here.

I have tried a tiny config with slub. There was no compilation problem.

-Longman

