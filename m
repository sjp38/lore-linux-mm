Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84157C46478
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:16:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48C10208CB
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:16:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48C10208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D82966B0003; Thu, 27 Jun 2019 17:16:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5A5E8E0003; Thu, 27 Jun 2019 17:16:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C483A8E0002; Thu, 27 Jun 2019 17:16:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5AEB6B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 17:16:20 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s9so3790864qtn.14
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:16:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=3evReopxioqJv9N92w6GNkBk5zeUjMeE5khMQzKKTBs=;
        b=q2uk8q1Ov8XmgSl3og3JgpViasyLEZlV9Q5u1RHf8Rz+yeFcm4xCXeSqpsI03nfzO8
         BgQ3W6BcD7qwqWcjPeVCsyyCzSgh4mPBDqmPS2sLoxY5E0IXdRFVajt2j5b0jQFD43Pg
         Q7E/YbZkJTR9z3igI8yxcaf7FbtBq//DEW6CjZ1jLQmbEz4brqNEBLR0S8rQ1p6Uh0Lg
         O1/8XY5UsVw01xHHTsUznebLjherhaIXoTqaDHbUqSYmjWy6ZhONsrHcu3qEqKIX9oRq
         xv7y8ouBmSStUPZiidYNZK27e22ECmlLqvr1YZhZU61rTZw36dsmX76niKKpKlS2B01r
         8ePA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXBNkplonnrd5rcC0nlGWUxOyTCTuNi+Hk2t1zME+2yqr7lb/x1
	ev3b48013tDYU2ljjaLIqcjdLsiR2T21cCaiKzLE3zJqh+A0f6tFGCwitSOZRqyHXPsO5eJhzGK
	t7Rhf5Q4kReFfphNva06+Li0X7jlvhbV6sYggPMlf0R8k4ZEuVTtEyep08POxUBSfGg==
X-Received: by 2002:a37:5445:: with SMTP id i66mr5634310qkb.369.1561670180458;
        Thu, 27 Jun 2019 14:16:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwucnjZdD+BOIlTdQI9PvWOaKMKrznncqjeCombonA/iwitrj3BVbgmXHEI6t3enG6CVdZC
X-Received: by 2002:a37:5445:: with SMTP id i66mr5634268qkb.369.1561670179968;
        Thu, 27 Jun 2019 14:16:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561670179; cv=none;
        d=google.com; s=arc-20160816;
        b=G1uWGCDX2zz087ALHWerzsAP5TdLr0SFIRh2BU3tbhw01YT9QGIsued4P33Rb6jnrR
         VN+8vOaJUq1/lohjbO29/lN0Z9w10TETy4ExBn0UfgH0Q6wLEsPwcp9mo/0PpRL5wiNk
         tGtwJX8IR+dQ8ZDXRKLJl6mI90xFVolR4Q38s0GAleaTpcK5i017N28iz+RPDwaP1RA6
         ro7QNeoWrYfOEvGqV5745Rau+WlJ3J9cbJDQlRTqt9GaxYp5VhZBI4QUnoKM3gpGbcfV
         Jc06cWTVatmHFstFhYqyUXGwCpaJzk6nDXCRAHgauPxbRhLYO4WgGnIyoOCWlyY30qpP
         Se5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=3evReopxioqJv9N92w6GNkBk5zeUjMeE5khMQzKKTBs=;
        b=p5oCXN0X1+heUOVjmENjUaymxtwRA4nPuNCkiS2MArYCEs5xcnmVGnN/xMo/DNgZx6
         asSrvik5oJYW2S+sC7RGpL6C1COeRORcLlIqyEmez7DTpKgulPyczQLmyANwkwVW80Jy
         Y1sDPUDM3h8Rhl9DDahSFlpuLuswME0jKrTk4KPHZB6XF3qiBtdLDrQBzulWnK6eYXNp
         u0F1N7bhVALuvNNEaHzHUmVztlGex1bppBZ51cXT47mAknIExUpuhjL/nmlrXCSiHNMo
         eRkgzBGmjOgSnKqeAVqDvPWmuaUlhT8NTg/oGlc37mK4ERB1zTBLPKruD01MhylcmEAq
         VX9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t53si176656qte.224.2019.06.27.14.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 14:16:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 764DE3082A28;
	Thu, 27 Jun 2019 21:16:13 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7EC455C1B4;
	Thu, 27 Jun 2019 21:16:04 +0000 (UTC)
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
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
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-3-longman@redhat.com>
 <20190627151506.GE5303@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <5cb05d2c-39a7-f138-b0b9-4b03d6008999@redhat.com>
Date: Thu, 27 Jun 2019 17:16:04 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190627151506.GE5303@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 27 Jun 2019 21:16:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/27/19 11:15 AM, Michal Hocko wrote:
> On Mon 24-06-19 13:42:19, Waiman Long wrote:
>> With the slub memory allocator, the numbers of active slab objects
>> reported in /proc/slabinfo are not real because they include objects
>> that are held by the per-cpu slab structures whether they are actually
>> used or not.  The problem gets worse the more CPUs a system have. For
>> instance, looking at the reported number of active task_struct objects,
>> one will wonder where all the missing tasks gone.
>>
>> I know it is hard and costly to get a real count of active objects.
> What exactly is expensive? Why cannot slabinfo reduce the number of
> active objects by per-cpu cached objects?
>
The number of cachelines that needs to be accessed in order to get an
accurate count will be much higher if we need to iterate through all the
per-cpu structures. In addition, accessing the per-cpu partial list will
be racy.


>> So
>> I am not advocating for that. Instead, this patch extends the
>> /proc/sys/vm/drop_caches sysctl parameter by using a new bit (bit 3)
>> to shrink all the kmem slabs which will flush out all the slabs in the
>> per-cpu structures and give a more accurate view of how much memory are
>> really used up by the active slab objects. This is a costly operation,
>> of course, but it gives a way to have a clearer picture of the actual
>> number of slab objects used, if the need arises.
> drop_caches is a terrible interface. It destroys all the caching and
> people are just too easy in using it to solve any kind of problem they
> think they might have and cause others they might not see immediately.
> I am strongly discouraging anybody - except for some tests which really
> do want to see reproducible results without cache effects - from using
> this interface and therefore I am not really happy to paper over
> something that might be a real problem with yet another mode. If SLUB
> indeed caches too aggressively on large machines then this should be
> fixed.
>
OK, as explained in another thread, the main reason for doing this patch
is to be able to do more accurate measurement of changes in kmem cache
memory consumption. Yes, I do agree that drop_caches is not a general
purpose interface that should be used lightly.

Cheers,
Longman

