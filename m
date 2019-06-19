Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02E0FC46477
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:47:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD8D5217D7
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:47:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD8D5217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BDBF8E0003; Wed, 19 Jun 2019 11:47:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46CAC8E0001; Wed, 19 Jun 2019 11:47:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3823D8E0003; Wed, 19 Jun 2019 11:47:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 172738E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:47:48 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s9so16326526qtn.14
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:47:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=C64JjeOkHKlLr4rTKGwq0Str/b64u3T8iBmdsSuGT/A=;
        b=GKYkph2aKP8G5LSvnV2ekvM+LhRp0v1Ar4man+RDaKc3Pacy81+S1O1aLJKGTIhW3e
         dAizvx98gwbAK3yeueXa9VllBMfVOOwypUasO4CfXgZbD2qngm9ESYaGXzOkuyDOjA9r
         MCIPmFQDR12RB4AYQLJV9KoE5lM44bHVRuAb1sD6LGh43TtsPgJ96chQ8kcA4G5MfKe2
         coQfjy+ztGOxsSZXb+g7MiI0X6AppY1UuIxAgv8EMWEFJzD9cS7Aei+mSIVTXA+lxAjk
         VZTPprxLSZe3BVx0V7zE50DH/reEE03mm3MZJQJ5bBx/qrA7pLPwZ8qYZtGfhDbdHubV
         rRCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUIhTjJsmGRABrOmG9R7tw7odLvM5QvsHkva+bzQ7RjNzCFHjou
	A9VN13LZZICqiFJtIlASFzvPbWMUF5OX0rfMdjrFuLlnjL94St11Y1jT974ZTyWmf1780L9l8jv
	H1s/RBWZ6ovA/rsiktuk1xiL753AzKXiwo20IR9VZcu1W4Nj5cXqWiB0P3IVUHLP82Q==
X-Received: by 2002:a37:c448:: with SMTP id h8mr75580954qkm.308.1560959267887;
        Wed, 19 Jun 2019 08:47:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbdPT3dYwlRtHeYU4W/3pDBHv5I+dm6jOjjCKWGxlb6tEZ2QTSD1icPShOsu4gXjWWibj/
X-Received: by 2002:a37:c448:: with SMTP id h8mr75580917qkm.308.1560959267445;
        Wed, 19 Jun 2019 08:47:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560959267; cv=none;
        d=google.com; s=arc-20160816;
        b=rcX44tN8E5zh7+AOqFKiG52dF3NVSiXWz+dEmNM3+SivjKjDUOeHnyTtB+cGw5iWr3
         uvBFf5pKLDh0TDr+AI/aLkORBW8LMkkmVdV8g34/4OYwnR2RAoaCFnE0TIIY1mpxJRab
         NQoYSUunnQMMrlxIrthkc1SZhTon1/c7BZFLGsU4ZUXsF0RrtVzIvMqo8+YSzGdHw38a
         8dqb+JZS+NhhbI/iaZ1ANlGUV5Mdrijwu94VMW9ETyW1/+WP/TBF/y8cwrcZZ/e+fO52
         WoAvTWBWrJC8FvSTeI0dc305TpDSoSHcDmyq8F7eL9abl6gkggjjJ4sKo7UkziK9aRI5
         GlKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=C64JjeOkHKlLr4rTKGwq0Str/b64u3T8iBmdsSuGT/A=;
        b=yrZwytcABsjDxrDI1V2XH18a0/pM6P/V47KFM6/PoaJFoAxoNlR2Yv1xMLrL8LTU6h
         9MErAjcJEW04GzUr7JtNHz/PeHaLKiFGLS9zu1+GRtN9VNF3/36kwD3vnj9fKAXIXYuJ
         Z2V3Dq5IjRBPH9vK9pdmZSkFTljFWfO3NPwJtuhP0Br8aP+o4oh5R0T5CSf0yVLToeJ3
         jkna8xXiq+VVDM6dhyeOKf4MV7iX9senCch25/onAmLntmFjrT1JlQGt/7sabCRrqSL+
         A7dLxu+ylf4D75v1ibXZNd1YyHXiTZZiVexicRUCx6bj91K9Ly950vMM9SU89tKt77uQ
         TWQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o41si538218qtk.223.2019.06.19.08.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 08:47:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 42C843078AA0;
	Wed, 19 Jun 2019 15:47:42 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8DEEF19C6F;
	Wed, 19 Jun 2019 15:47:40 +0000 (UTC)
Subject: Re: [PATCH] mm, memcg: Add a memcg_slabinfo debugfs file
To: Shakeel Butt <shakeelb@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>,
 Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
References: <20190619144610.12520-1-longman@redhat.com>
 <CALvZod5yHbtYe2x3TGQKGtxjvTDpAGjvSc8Pvphbn00pdRfs2g@mail.gmail.com>
 <20831975-590f-ecab-53db-5d7e6b1a053f@redhat.com>
 <CALvZod6T31z2P+wdUz3LVYO3dTSbOc89cKDn=8LKpN+ZovL8jw@mail.gmail.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <a33fba37-ef61-8179-9994-df7e04cc5866@redhat.com>
Date: Wed, 19 Jun 2019 11:47:40 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CALvZod6T31z2P+wdUz3LVYO3dTSbOc89cKDn=8LKpN+ZovL8jw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 19 Jun 2019 15:47:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/19/19 11:35 AM, Shakeel Butt wrote:
> On Wed, Jun 19, 2019 at 8:30 AM Waiman Long <longman@redhat.com> wrote:
>> On 6/19/19 11:18 AM, Shakeel Butt wrote:
>>> On Wed, Jun 19, 2019 at 7:46 AM Waiman Long <longman@redhat.com> wrote:
>>>> There are concerns about memory leaks from extensive use of memory
>>>> cgroups as each memory cgroup creates its own set of kmem caches. There
>>>> is a possiblity that the memcg kmem caches may remain even after the
>>>> memory cgroup removal. Therefore, it will be useful to show how many
>>>> memcg caches are present for each of the kmem caches.
>>>>
>>>> This patch introduces a new <debugfs>/memcg_slabinfo file which is
>>>> somewhat similar to /proc/slabinfo in format, but lists only slabs that
>>>> are in memcg kmem caches. Information available in /proc/slabinfo are
>>>> not repeated in memcg_slabinfo.
>>>>
>>> At Google, we have an interface /proc/slabinfo_full which shows each
>>> kmem cache (root and memcg) on a separate line i.e. no accumulation.
>>> This interface has helped us a lot for debugging zombies and memory
>>> leaks. The name of the memcg kmem caches include the memcg name, css
>>> id and "dead" for offlined memcgs. I think these extra information is
>>> much more useful for debugging. What do you think?
>>>
>>> Shakeel
>> Yes, I think that can be a good idea. My only concern is that it can be
>> very verbose. Will work on a v2 patch.
>>
> Yes, it is very verbose but it is only for debugging and normal users
> should not be (continuously) reading that interface.

I am not against it. It is just an observation. I still think we can
skip kmem caches that don't have any child memcg caches as the
information is in slabinfo already.

Cheers,
Longman

