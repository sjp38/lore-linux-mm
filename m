Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14264C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:37:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA6FA20873
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:37:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA6FA20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71C236B0007; Thu, 18 Jul 2019 10:37:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CD266B0008; Thu, 18 Jul 2019 10:37:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BCBE8E0001; Thu, 18 Jul 2019 10:37:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE2E6B0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:37:05 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id h198so23400413qke.1
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:37:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=KwTBvK6zXDUSlUosZQWtOpNlgy8yUy48FWLBaO4pbh8=;
        b=DPolggLciVrP8tGqWSjV32YsvMFQbXCX1vEz4fJ7H+HNpsp2+9djlavQ+ho78hkf8+
         k6dfM5BiY4tINECSC0bcn+ePGnC0qa1hoTkbKP+VtLShPXtF9Ud2X9NKxe6zLA0Vg0w9
         5roDJkK2wyU+Z2u0txRt8kRM5Q3eoaltlREtM8aMFALnE+djkkirv1JSo8iahAtX/26K
         THA+oD0fhSxMLLuyymck5wvy+P16KewpDlw7dC+MDgX6S7sSe7TZ8P6tdMUBGWUAw6h9
         JkkCkstpa0gCAQUBzKzIT25FF5thfjs9fUupk4pz+hT1DAWoes6KyHA/RH7Zk3aVGqKt
         dQZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX0HArKWi+u/kjRGzxJFK/W/+uh8lHnDbrqAH9XvWJkCdRxJ2l/
	DRP76Zy1t3ticaxsQCjGk1BsSGupEUArxMQf8t7rLIY4tVhaesPkRlLs2kDxiAVRFw2Y57qAR2B
	zV4DJHZdmoTSYZ/D7USCw3+6nQMjl3Z9IfmSR20xPUDjDROt5C9npK5P52swWFji8Eg==
X-Received: by 2002:a37:9c94:: with SMTP id f142mr27959123qke.427.1563460625041;
        Thu, 18 Jul 2019 07:37:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxShjtuXarWZHeDPhsp+Ei23MTKaq1ajiMgwhIcSvZO9ugkWgnZqHsJTPghyeqF5HMYilZ5
X-Received: by 2002:a37:9c94:: with SMTP id f142mr27959080qke.427.1563460624456;
        Thu, 18 Jul 2019 07:37:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563460624; cv=none;
        d=google.com; s=arc-20160816;
        b=NI6ntG9X0Dqw1rxhTvtow24mS7c61X17HnKrVzye20RtNhIJJqTgYRToiw9IM9CDAO
         8goUwLdCp9xSTR4J9srCJ629vi8USd2VJnIaDj5Sbdut2r8SDVnFv14fyG+SPpOZSVTp
         dHL9o46vZMV97bGOwMG8orlnQugcpbAkcQcbA7MG142t62o74OEgHP/DdJ+fJIMhr05e
         kO9UB7/1txt+tYnzUUES3xhTbdFpdR3oQaaqzeVdOKyxeIOTYbDFkwZ6KWqJKYm5Wyr8
         xL6RCBPcmE9m5qGdsAcseG2G+yV9pZWOl9x1rU5uztyFg0ZtzeWmTioJN3Q7MXdTPHt3
         KMwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=KwTBvK6zXDUSlUosZQWtOpNlgy8yUy48FWLBaO4pbh8=;
        b=IP0OXtwl6dCzULiQiDe0OyePd4NRVPvbVypd6Kz0T7LCB13Pk3ERQXFu6ek/8I+noa
         THf1FLMf4v9JdHWxzD1nRzV4Nx/127B4sZdJmYzXInjJYn2f3GjAmKVZvDj1VVlGFni0
         JACXWbRxtxM2VeE6+uUOwwGWKfprpn/sRq13qIhiqWuR0mHqMzJ7Ew/gSdl6M/X4rdjM
         oqHWDZOYa6o1wxSvbEaY0WiwcNpt38gIuzb6mVSbFNcGBfFEC1ovvD6HcxqB/awmz1hx
         iaMGH1QKt2vKGhbFlJnh/HHRTWjivAt/47ZI6Ih7NEEs6mi2G5YgkaOLWoWkbbgOHx17
         qtFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s129si16473731qke.252.2019.07.18.07.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 07:37:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8C258C09AD0F;
	Thu, 18 Jul 2019 14:37:02 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 14D3660576;
	Thu, 18 Jul 2019 14:36:59 +0000 (UTC)
Subject: Re: [PATCH v2 2/2] mm, slab: Show last shrink time in us when
 slab/shrink is read
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
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <6fb9f679-02d1-c33f-2d79-4c2eaa45d264@redhat.com>
Date: Thu, 18 Jul 2019 10:36:59 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <0100016c04e1562a-e516c595-1d46-40df-ab29-da1709277e9a-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 18 Jul 2019 14:37:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/18/19 7:39 AM, Christopher Lameter wrote:
> On Wed, 17 Jul 2019, Waiman Long wrote:
>
>> The show method of /sys/kernel/slab/<slab>/shrink sysfs file currently
>> returns nothing. This is now modified to show the time of the last
>> cache shrink operation in us.
> What is this useful for? Any use cases?

I got query about how much time will the slab_mutex be held when
shrinking the cache. I don't have a solid answer as it depends on how
many memcg caches are there. This patch is a partial answer to that as
it give a rough upper bound of the lock hold time.


>> CONFIG_SLUB_DEBUG depends on CONFIG_SYSFS. So the new shrink_us field
>> is always available to the shrink methods.
> Aside from minimal systems without CONFIG_SYSFS... Does this build without
> CONFIG_SYSFS?

The sysfs code in mm/slub.c is guarded by CONFIG_SLUB_DEBUG which, in
turn, depends on CONFIG_SYSFS. So if CONFIG_SYSFS is off, the shrink
sysfs methods will be off as well. I haven't tried doing a minimal
build. I will certainly try that, but I don't expect any problem here.

Cheers,
Longman

