Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA318C28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 17:09:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86B1920652
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 17:09:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h4YLVhvO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86B1920652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF80B6B0005; Sun,  9 Jun 2019 13:09:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA7756B0010; Sun,  9 Jun 2019 13:09:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B96146B026C; Sun,  9 Jun 2019 13:09:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56A146B0005
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 13:09:10 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id r84so816752ljr.22
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 10:09:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=SVFb92jStOUm7FrDt2zzfDZopbwt0k6o8Y+bNfKiHmE=;
        b=Xx/A/RezHvTBA0loav21bAt8gB5kNkySPidg72cTYYkfDUd9nr0JtpXs5FOC/faRrf
         5mqN8OWUTI78V/WhvLMXlUuL4JS9aYyFhe6+zp837MheZTClSsGkDxm+3MIQB6ENikW3
         t5whKC/Np8nj8pcAe2OyNCHfNtdY81st+Q6WkYqHv/7jWdOvN7lbjDuaiTHHgHhpf5KI
         phpXEnQSDpqdIZS7fN5dzk4AG2ZP9yCxvRoDA1jLYl38UpOQRr25awc6xlq14yK9FgJI
         lQIUSR0BWQlJzABrpiBLDchp+FzjDLzhGzsriSgWtGQmexf2pSv6z7vlRU5aaSBkQAK2
         7f6g==
X-Gm-Message-State: APjAAAXF/DCuNoCX/tgqM3c2UuRBB6MCEa1UEDEasmGALllqK5aEzr5p
	OnwOlYoAb3ec3kmTpv/pCJHf2EbJRIWU5vtgE0sFMQ6EgE+tC7DfvJ0iA2Zsn2jU1iO8T6+apex
	MBmfM3XSoDLaagAtI/3uNndMcZJbBMjnvsCX6kXuNvcs8VeaM/Jt50GivyijiHfz8Lw==
X-Received: by 2002:a2e:970d:: with SMTP id r13mr22593690lji.126.1560100149514;
        Sun, 09 Jun 2019 10:09:09 -0700 (PDT)
X-Received: by 2002:a2e:970d:: with SMTP id r13mr22593646lji.126.1560100148213;
        Sun, 09 Jun 2019 10:09:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560100148; cv=none;
        d=google.com; s=arc-20160816;
        b=kw/Fvcw+bbgVi9zcGwb4yaSFipVC/Ot4JwujHfXAFkiwbWsE4wbvPkqvv8HZ4SGoaw
         Khzwi0ydw1DBGuxQAgl8Z+M/UBwUCrQDLOqFNTUhMGsdT+x62bEKb8zec658ovq7fXz8
         nIhRM2Cd3DohAFWMrrw0yzjXbnrLcgwxgpXLqQAvnyDwEmwo5rge6J504r0KiPLfAqqL
         BAwcEG1+GCpuZcOWt2SafckP4thk0kpPWEvAKzswINsbu6VqGSUsRzhBCiaKuKwatS5X
         miCK4O00Qho1sQ96vwt108w9Zg4o+Ndf48Q6I49X2f7CQVa0hEXmAIIxwOn3VJ0Oz9ig
         J18w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=SVFb92jStOUm7FrDt2zzfDZopbwt0k6o8Y+bNfKiHmE=;
        b=Yuo08z3zvIOE7+r/G5mjHonQXE467c6aZk7hKu3eEPFcIF9GRnTOWUpYTUwHIkcX+Y
         79soMitr6x12oRogXgxRj32UyJl7mA0eb3yDebhPx7Svth+rwnDoIfGjSSTD1xwVktW1
         vKhN+Zvk4vT/JOcFyX5e5/TNkwgCt8W6mttv/5RwLp3TTqNe2qfBDZd5ehZtcLaMp2cN
         OXuXfS7dWw2wEe5UDdUH95F9QsoacS5algMpInB66oW8asnQbDDhX4vQQhKdjG6Mcwpf
         h9MVJ/jZm58TuCnsqYUeApcG7SktPC8K/fgyhfsbrmekFMtHcqzTTapuR7S1gq0K4QM0
         EYoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h4YLVhvO;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor3760067ljh.26.2019.06.09.10.09.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 10:09:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h4YLVhvO;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=SVFb92jStOUm7FrDt2zzfDZopbwt0k6o8Y+bNfKiHmE=;
        b=h4YLVhvOorSOqenh/f1Bfik5jof3C1oJr99L3BAEiC30vXLOQLOhta3DqN4cFuMrCR
         kSmzIPGSe/Df4sups5Foy+UBkAZH4ekAUvk9e6N+B66TEvfAFoydIYEVuuwY0NhkwWQ3
         nJLOuQRDuyTRYaLHNZ/ho/m/l2oLJGg6FaQ3C6WST9e48H+dneVBxl/uig9D7xxGUMzs
         4CZGlQ75U1yTg3/yuLOzHmedlR6sJdUekPgbSJ957WA4J970PfsjWWxfPTKUY77cLODe
         IPUjzyXe4PSD22yUDhEx7M9aB7b7lcWkbcDJggLnP9oubHGHtwHHZYY6buIeEGacHViB
         H7zw==
X-Google-Smtp-Source: APXvYqyRZvryIGVQSMSxXuuKTyXUevEcqVa2kex0G0TyMjAyk4fYU9KhM7x7/Cu5vz9PNqHqSRma3Q==
X-Received: by 2002:a2e:9e07:: with SMTP id e7mr15412972ljk.55.1560100147772;
        Sun, 09 Jun 2019 10:09:07 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id x29sm1513881lfg.58.2019.06.09.10.09.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 09 Jun 2019 10:09:07 -0700 (PDT)
Date: Sun, 9 Jun 2019 20:09:04 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 08/10] mm: rework non-root kmem_cache lifecycle
 management
Message-ID: <20190609170904.nxa2rb6inkvx3geg@esperanza>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-9-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605024454.1393507-9-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 07:44:52PM -0700, Roman Gushchin wrote:
> Currently each charged slab page holds a reference to the cgroup to
> which it's charged. Kmem_caches are held by the memcg and are released
> all together with the memory cgroup. It means that none of kmem_caches
> are released unless at least one reference to the memcg exists, which
> is very far from optimal.
> 
> Let's rework it in a way that allows releasing individual kmem_caches
> as soon as the cgroup is offline, the kmem_cache is empty and there
> are no pending allocations.
> 
> To make it possible, let's introduce a new percpu refcounter for
> non-root kmem caches. The counter is initialized to the percpu mode,
> and is switched to the atomic mode during kmem_cache deactivation. The
> counter is bumped for every charged page and also for every running
> allocation. So the kmem_cache can't be released unless all allocations
> complete.
> 
> To shutdown non-active empty kmem_caches, let's reuse the work queue,
> previously used for the kmem_cache deactivation. Once the reference
> counter reaches 0, let's schedule an asynchronous kmem_cache release.
> 
> * I used the following simple approach to test the performance
> (stolen from another patchset by T. Harding):
> 
>     time find / -name fname-no-exist
>     echo 2 > /proc/sys/vm/drop_caches
>     repeat 10 times
> 
> Results:
> 
>         orig		patched
> 
> real	0m1.455s	real	0m1.355s
> user	0m0.206s	user	0m0.219s
> sys	0m0.855s	sys	0m0.807s
> 
> real	0m1.487s	real	0m1.699s
> user	0m0.221s	user	0m0.256s
> sys	0m0.806s	sys	0m0.948s
> 
> real	0m1.515s	real	0m1.505s
> user	0m0.183s	user	0m0.215s
> sys	0m0.876s	sys	0m0.858s
> 
> real	0m1.291s	real	0m1.380s
> user	0m0.193s	user	0m0.198s
> sys	0m0.843s	sys	0m0.786s
> 
> real	0m1.364s	real	0m1.374s
> user	0m0.180s	user	0m0.182s
> sys	0m0.868s	sys	0m0.806s
> 
> real	0m1.352s	real	0m1.312s
> user	0m0.201s	user	0m0.212s
> sys	0m0.820s	sys	0m0.761s
> 
> real	0m1.302s	real	0m1.349s
> user	0m0.205s	user	0m0.203s
> sys	0m0.803s	sys	0m0.792s
> 
> real	0m1.334s	real	0m1.301s
> user	0m0.194s	user	0m0.201s
> sys	0m0.806s	sys	0m0.779s
> 
> real	0m1.426s	real	0m1.434s
> user	0m0.216s	user	0m0.181s
> sys	0m0.824s	sys	0m0.864s
> 
> real	0m1.350s	real	0m1.295s
> user	0m0.200s	user	0m0.190s
> sys	0m0.842s	sys	0m0.811s
> 
> So it looks like the difference is not noticeable in this test.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

