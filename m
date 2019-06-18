Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CE1BC31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 19:27:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DBC820673
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 19:27:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DBC820673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B0666B0008; Tue, 18 Jun 2019 15:27:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 939648E0002; Tue, 18 Jun 2019 15:27:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78BEF8E0001; Tue, 18 Jun 2019 15:27:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 532BC6B0008
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 15:27:29 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e39so13405796qte.8
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:27:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=FrdUxpQ44yvaY/S6tOtfIEd3I4bNffN9+zreRIMih4w=;
        b=C5Ds4AUDBS7F5kruw9Ga3GJcXzUGtPaYXUbvvt82apTPR7WTNRgGKLfbWIo2NEzyfI
         tCNIdptAbmhcdItaQ+Gl+nN0kfedB9B8Syl2mHumPP+204wITCFQw9rduRj8menIFAbo
         bOujXfLDVwHEDzg89VQgIn2Jy2dydmloYsR+WifVzrVMyATBXiejN1f5FkN3loukE2XH
         JUEueyRvcfcS8yAOCA6OBYIXzhTGIozxCKvo8SB6PiC7sL/ySudfG7C/f24+Krm5krBi
         Nq1mZOJX9s2+28N2rVMqJNUhL12CvfjYaLz9I+6lyCU5p3+6843S0ATGIvdaDiyUHcSw
         PTgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVs5CfbJLeKccGBITn1gacoMhXUNJEczCNjqZvt/fgBb9x/pFOA
	dbLyoBhrCs5qXKQ8+MBCP9MXla/HRA78S3NOoCdqQfY4xuR1srUD7apqiutrixr9QM0d+xgxB2f
	AXTOS6ubqNus9nhrfR8uFeirr8kozslDjikyOVzm+w3OcybNtFRBek2rSKsfLVZdgrg==
X-Received: by 2002:a05:6214:222:: with SMTP id j2mr28463695qvt.121.1560886049131;
        Tue, 18 Jun 2019 12:27:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRDwtYOndT5RIIzx2SUVtD7+x822ZTysKB2PqHssSRtsd7HrRgDpirnVK2R/kKd6Lx/A9c
X-Received: by 2002:a05:6214:222:: with SMTP id j2mr28463633qvt.121.1560886048482;
        Tue, 18 Jun 2019 12:27:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560886048; cv=none;
        d=google.com; s=arc-20160816;
        b=T7FInDmnd0JzwPddom4Oq1C2XWL69WOpDP69vxOC51zdNMWzLg0SlJ7edsbpyek7qL
         FeXJ0zsIqMIizPxzqXTAppAwnDBqt6z+G+sgnEEocJlb9KS62V2HK0v09PUWlmbZc+aa
         wt2xzcFpQdsRt5HAG7KLxE8komYPuWc1IPtBlk6uJCBBfqssm+TLwzj3mxNTYSQ7MRDa
         HdCi6B5tLqvE7y/f4YjN0fu/Kcc4Wk09zHL1lJ3Tm1dwYvIALZ3220GyMU/aEh43JSU3
         yXMmkn+jY/6ToKS4oKMe8Wh7BRd5htsVvSl4czsU7b5IKTqqUn9Cfto4XRv+stXe+OA+
         GRmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=FrdUxpQ44yvaY/S6tOtfIEd3I4bNffN9+zreRIMih4w=;
        b=OefEMGFPqAqKCZGXyKcQ2x/QRNGRPgSZmujIJUYIQ48SYMEGDUGJ22QFKQwf4HjQW3
         MFmGrqmW63euAvAD3AboCcFpVWr+VjA145MF44Yq4gy1GSfJotJ2nN4CbT+xlUbQZGDw
         uaLrO3bgBhcoaMM9JiabBxEP4p8Hrh5GfT3jOiesP/fzbFI8GAxlsSRPqtnKlnmYMVQK
         ULzyl9rx0MGNyU2nli6xhS+ObM1rDttge7rEuY+s0JhIwM2z2ZYdo9p5Wwl/6i2P9NP7
         zX1W6dHhXf857pxNBAisY5rZBFB6HaR9gfl7/pVWNnSz+TFs30DEH4bAPb8thOeKIuEa
         ICCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l67si10373227qke.45.2019.06.18.12.27.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 12:27:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6938458E42;
	Tue, 18 Jun 2019 19:27:27 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6D4CA19C5B;
	Tue, 18 Jun 2019 19:27:25 +0000 (UTC)
Subject: Re: [PATCH] mm, memcg: Report number of memcg caches in slabinfo
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-api@vger.kernel.org
References: <20190617142149.5245-1-longman@redhat.com>
 <20190617143842.GC1492@dhcp22.suse.cz>
 <9e165eae-e354-04c4-6362-0f80fe819469@redhat.com>
 <20190618123750.GG3318@dhcp22.suse.cz>
 <dee4dee2-1f4f-a7c9-0014-dca54b991377@redhat.com>
 <20190618183208.GK3318@dhcp22.suse.cz>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <681ed4dc-e8a5-afcf-98b6-c17544c6094d@redhat.com>
Date: Tue, 18 Jun 2019 15:27:24 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190618183208.GK3318@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 18 Jun 2019 19:27:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/18/19 2:32 PM, Michal Hocko wrote:
> On Tue 18-06-19 12:59:24, Waiman Long wrote:
>> On 6/18/19 8:37 AM, Michal Hocko wrote:
> [...]
>>> Is this useful enough to put into slabinfo? Doesn't this sound more like
>>> a debugfs kinda a thing?
>> I guess it is probably more on the debug side of things. I add it to
>> slabinfo as the data is readily available. It will be much more work if
>> we need to export the data via debugfs.
>>
>> We are seeing the kmem_cache slab growing continuously overtime when
>> running a container-based workloads. Roman's kmem_cache reparenting
>> patch will hopefully solve a major part of the problem, but we still
>> need a way to confirm that by looking at how many memcg kmem_caches are
>> associated with each root kmem_cache.
> I am not disputing usefulness. Dead memcgs are showing up as a problem
> for a longer time and having a more debugging information is definitely
> useful. I am just not really sure that /proc/slabinfo is the proper
> vehicle for that information. It might be just easier to stick it there
> but that is not the best justification for adding something we will have
> to maintain for ever. Not to mention that the number of dead memcgs
> might not be enough to debug further when we can easily end up needing
> to provide more in something less "carved in stone" kinda interface like
> debugfs.
>
Fair enough.

I will rework the patch and expose the information via debugfs then.

Cheers,
Longman

