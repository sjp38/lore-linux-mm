Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE3FEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:48:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ED9A2146E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:48:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="OnWbLuxJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ED9A2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E2B88E001D; Wed, 13 Mar 2019 15:48:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 093088E0001; Wed, 13 Mar 2019 15:48:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9BBB8E001D; Wed, 13 Mar 2019 15:48:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD10E8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:48:51 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id h3so3221080ywe.21
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:48:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ctaB5au7utl3Gx2JywUyoePNtfp/SVRLeNPeDseyDJs=;
        b=CXxdcO1Aj2qgMQ6HoEsCAMe5pEuUYnalH6Tn10f2HUFFFYYT+xXRVmWn10J7uDh4dT
         KJ3Hv57JUTOYsU7oxOTM5crkhw2Ery59NsEAC3Zb/mVgnLtU/phuSJTx8PvZ+QLLKXyW
         F5qSW9r1hZUfFszSbYqTeAjh5SBB9K8V7Isix2p4KWJOxhlbfCSomdICIvztYnCYxwBn
         nEcAapJpRy3IDW/PPWjoNUh8cb3NCUXY5CaCojMbvVp00d2iDt+eTkBgZcftIlVx/fDQ
         c19iuJ2ryn7XUnG/cqRSgUgTF5sA/U2YshY3fXdS711G5i2/HdxEAC3S/9CWu1/Zt+SV
         3R6g==
X-Gm-Message-State: APjAAAV8rTQWL+s6lCJnYY4OOjYb+8VWF7bOCCo2ph5TWRDGxS2Ifrfo
	GJe/TnN9wssZ9puj65H/TT23sLhFuYxgxzutQK4MTG+WSzocyqP4zUhifBzAfBTKWB+ThzarUN7
	tegChDFLl+5dJYeX6R9lk0wIyIYaM9GGDzGJd1vUEzbMPsL6jkzUuG/zGnwbslUw6h1hE/5YFu8
	LcnELDgsH8iEdmlt6jmbwwQL8RxvP6g37rneECRtN8PEKweHfEWlj08q4XUc1qXFHM5UaSIfwxn
	+h3q1Yl2PBlvGMSjo6WVYvxjmMLE/NlR6m+j2iLsMRMMsSqaWwB89Li+rI4rko49cUlCGbfzm2p
	PvUClnIoJdwbh8cUDl5FCTv6sLh3NuIkhZvqr483BD7nzrxhw0GqJ1PcITzaYSzEUE0te/kfhUt
	J
X-Received: by 2002:a81:142:: with SMTP id 63mr36676145ywb.119.1552506531392;
        Wed, 13 Mar 2019 12:48:51 -0700 (PDT)
X-Received: by 2002:a81:142:: with SMTP id 63mr36676111ywb.119.1552506530591;
        Wed, 13 Mar 2019 12:48:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552506530; cv=none;
        d=google.com; s=arc-20160816;
        b=wHDgGqr1FeYUsr7bAEBhIdTOR70xUAwPGUXqn72xsk2KlcQ4g+tQeFv91AJW4nVGXf
         uHEwuslIwg+hvj3hdyaiS8YLCldKIYtebTwVYowi3mSbfMH/P4TSPog8xINB3BI5JydG
         zmMHUZBpHrqvYt49FsUEQX40VM+CbPhzCJL4rNwvWJ5wfhgsbm1LO8VkTvy2lKsJb2pp
         01BQCtgpBfA2TSoPljUlcj+MRvj9UcUSsI4ul2l2wLdjuJ84xe+DyE/vfnBtjGgYR8dP
         7ee3B+yYtcT7rlicL0whb7WE5eZTXn6zkqbPTBquRcRWZTiWtmEgvduvKmF7Bo2OEFsd
         Jttw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ctaB5au7utl3Gx2JywUyoePNtfp/SVRLeNPeDseyDJs=;
        b=iV5Vk7ThrALrj5kpRWwDqPrbtI3vzpFmRwpqnUnKfVVKCdc6yLaWHxXSn0yQAvWpb6
         xc0pggP4kUPR0Q010TBXsP7ZyRFfBRREg5J7htlyS3nx2aUmWQmLOiFAS2tLthosLML3
         7I+x6JTwH0GxNNQ0tG5aps0JYvTahc9nxX7Tqv+5i863UexRPURWSq2789vafFaluahN
         sIyph8BhR9uTBKVj1Ely22wrMuGxLu4GqMHB+S9fFG/4ZWF1ug4wcxA5+SRf6oXywz1w
         MigR0xouM6XaNUjTW25IUbHf9aHKNw3W2A0JeLeaQ0bEYpPmBP1KhQqL/FqaXAxjxl1i
         QxeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=OnWbLuxJ;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b190sor1593976ywe.142.2019.03.13.12.48.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 12:48:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=OnWbLuxJ;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ctaB5au7utl3Gx2JywUyoePNtfp/SVRLeNPeDseyDJs=;
        b=OnWbLuxJUnJM/J0oMb5kwfpcPSBBvgndkRUIdj1Of5FyPfO08VbDXbFmlNVzmRVL4p
         mQUwSvPlqYMcNLAJ8YCO7rRrcAV1iQfb8V4MXysCtaiVX9tmNvRZyAhzulMzdmbBNBPe
         MUO0U1YNBaS7QOW7PfCODPfZx/VPVPHBWGL7tP6MRvtki+Lt3mB6HiAy+qhMUcq6qaE9
         1mJmoPPW8nM2UUjSlsB8ZZLSjXXvTKmQKacK0PgYLsvmmpBn6wVl3F3yTeaffyzrXKDg
         F904F9pO0vhglCrjhO8Rw0eeAEUHQDraSLAuvtSFLxPt9PbJ5TlwYTocy0p0jtiSADoj
         1xfw==
X-Google-Smtp-Source: APXvYqyAlTREA7MYT/TBB0yTNoQ3Snqb0+I/lcx9HWdX+jEh4Hya3vdEqloX9ZGZMvipUA07u+QWRQ==
X-Received: by 2002:a81:c546:: with SMTP id o6mr4753314ywj.508.1552506527798;
        Wed, 13 Mar 2019 12:48:47 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::468c])
        by smtp.gmail.com with ESMTPSA id h5sm5599866ywh.3.2019.03.13.12.48.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 12:48:47 -0700 (PDT)
Date: Wed, 13 Mar 2019 15:48:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>,
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 6/6] mm: refactor memcg_hotplug_cpu_dead() to use
 memcg_flush_offline_percpu()
Message-ID: <20190313194846.GA6683@cmpxchg.org>
References: <20190313183953.17854-1-guro@fb.com>
 <20190313183953.17854-7-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313183953.17854-7-guro@fb.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 11:39:53AM -0700, Roman Gushchin wrote:
> It's possible to remove a big chunk of the redundant code by making
> memcg_flush_offline_percpu() to take cpumask as an argument and flush
> percpu data on all cpus belonging to the mask instead of all possible cpus.
> 
> Then memcg_hotplug_cpu_dead() can call it with a single CPU bit set.
> 
> This approach allows to remove all duplicated code, but safe the
> performance optimization made in memcg_flush_offline_percpu():
> only one atomic operation per data entry.
> 
> for_each_data_entry()
> 	for_each_cpu(cpu. cpumask)
> 		sum_events()
> 	flush()
> 
> Otherwise it would be one atomic operation per data entry per cpu:
> for_each_cpu(cpu)
> 	for_each_data_entry()
> 		flush()
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

