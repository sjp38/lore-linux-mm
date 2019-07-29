Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E144C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:37:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06D3C2070D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:37:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06D3C2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A92C28E0003; Mon, 29 Jul 2019 11:37:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A431E8E0002; Mon, 29 Jul 2019 11:37:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90AB18E0003; Mon, 29 Jul 2019 11:37:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAE48E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:37:50 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id b85so26622343vke.22
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:37:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=gC8MExgYn0xfQlLGf7vnCj4KnLvnunZ3t62f8U+o32s=;
        b=ktt1sAtNFEaMc/5DD1rj09xxCGU2jYvY9IGCEGiHZdz2mcwouDVEoGRz/bH1wVrqVk
         udrd9++yJAGOw2eCH5VRtqkfIcgto2T8LHfLkGvVbSul2FBK8PZ9XRKfqiRMeFlygBTL
         b82sth9uBWvGqzod/RGo8JeltdmEzWmPkfus6q9p8wdOJBC6dg8Np+XXLssFAuv6aE4R
         38ho/uZvMlRodzq2T/tebmmJOMVNL+bmWdSUJ6zkfHA7VFhkOzpLHDfNP5ZXDMncIzZ4
         a7DkJ6oWRPLHrqKhZYRzj3g9zZmj99hLw+aPRc2MdTMS1xPjzOsdp0R6rlTds2+K6bx6
         7gfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUq1rU63YbHxEhRJYjzFIVwEJ7JhMB9CrqW+WNJcMmHp6Peutfl
	Fv42u45xM0OzGYPSeGuH0NtfWVkuEhz8hxfVrGEyXBfUs6f21LfL1O5dFdJCklF+uZRwjmcgOPZ
	5j0qNWZlyi4X/sz43laDnQO8vgAfKf9EQT5vMEsamut6d2efAIStSVw2RqZkWe7KgWw==
X-Received: by 2002:a67:bb03:: with SMTP id m3mr17798305vsn.84.1564414670172;
        Mon, 29 Jul 2019 08:37:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdgTNj5BBODyCCzU0zjNL5UZvS+TiGJPq0LjnYDCv1L4IImNIy/UX5IPVgv3TuTQMvEeEl
X-Received: by 2002:a67:bb03:: with SMTP id m3mr17798249vsn.84.1564414669679;
        Mon, 29 Jul 2019 08:37:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564414669; cv=none;
        d=google.com; s=arc-20160816;
        b=GfKlTuGpaczlgDfOaXY3iNv+xA7BUlL2WnL3n55BSSjZE2+HrmWOUXvr2UCi1d92yM
         Miv3eP27Pxafj//6p5ETR8H0+Co6XKw/BI4f9UPbsH4vCVd0+C4iR9zMJ5Z6jfqyBwup
         3gfMIJRx8HEKJWCUBRG5x4nocaN3TXx5icZeDRs058tULZM0Rc2rlizXeyKNLBkihdPD
         8v/L9nGGLYw7L06Qx1aqxwccRd6SsOgToZKFFXg11QOKYA4AmQOjD9D3U2PrYYIzlCMX
         rI2W4x1w5gaKAu5E/1Q671L6jxm082NClD2qyAvTuzPd5SRgtk44wmq1qdpLyQnujxY0
         qA2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=gC8MExgYn0xfQlLGf7vnCj4KnLvnunZ3t62f8U+o32s=;
        b=nB2A90NsQ7QOcnwxpZFDXcFmauGiH//dhGv1T9EShSSi9rS/ZZHH9gHwo1262HBs44
         uymIqAHR00kP0giCDsClIIHcttSiDyht/wOuVNI4VqDgdS3NCWuccIdvYicVRU9r6ii/
         VQ5n8/gpCQpqoyFMezbYV11yxkx1qT6WCp7K3r+Bz7R1RJLj3P6IH9KExNtaUEmDTbxT
         CxNHxroq9Rv8vO5+LYLh12ToRcHYkNOtu1xBXbQaxeKrfapv38d32XAqkv+fGk6UsNe3
         lOgzdBEJiBPRvuHNMLBYJfIo/cljVjFyG0Ej9Tm5BkSMUyIggQAbBb8Ju2OK00+i8nNE
         ensQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 45si13985253uan.40.2019.07.29.08.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 08:37:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DE805300CA4D;
	Mon, 29 Jul 2019 15:37:48 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 11B105C1A1;
	Mon, 29 Jul 2019 15:37:47 +0000 (UTC)
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Phil Auld <pauld@redhat.com>, Rik van Riel <riel@surriel.com>,
 Andy Lutomirski <luto@kernel.org>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
 <4cd17c3a-428c-37a0-b3a2-04e6195a61d5@redhat.com>
 <20190729150338.GF31398@hirez.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <c2dfc884-b3e1-6fb3-b05f-2b1f299853f4@redhat.com>
Date: Mon, 29 Jul 2019 11:37:47 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729150338.GF31398@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Mon, 29 Jul 2019 15:37:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 11:03 AM, Peter Zijlstra wrote:
> On Mon, Jul 29, 2019 at 10:51:51AM -0400, Waiman Long wrote:
>> On 7/29/19 4:52 AM, Peter Zijlstra wrote:
>>> On Sat, Jul 27, 2019 at 01:10:47PM -0400, Waiman Long wrote:
>>>> It was found that a dying mm_struct where the owning task has exited
>>>> can stay on as active_mm of kernel threads as long as no other user
>>>> tasks run on those CPUs that use it as active_mm. This prolongs the
>>>> life time of dying mm holding up memory and other resources like swap
>>>> space that cannot be freed.
>>> Sure, but this has been so 'forever', why is it a problem now?
>> I ran into this probem when running a test program that keeps on
>> allocating and touch memory and it eventually fails as the swap space is
>> full. After the failure, I could not rerun the test program again
>> because the swap space remained full. I finally track it down to the
>> fact that the mm stayed on as active_mm of kernel threads. I have to
>> make sure that all the idle cpus get a user task to run to bump the
>> dying mm off the active_mm of those cpus, but this is just a workaround,
>> not a solution to this problem.
> The 'sad' part is that x86 already switches to init_mm on idle and we
> only keep the active_mm around for 'stupid'.
>
> Rik and Andy were working on getting that 'fixed' a while ago, not sure
> where that went.

Good, perhaps the right thing to do is for the idle->kernel case to keep
init_mm as the active_mm instead of reuse whatever left behind the last
time around.

Cheers,
Longman

