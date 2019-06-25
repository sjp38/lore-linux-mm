Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0A6DC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:57:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CE0520869
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:57:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bHr9RG0t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CE0520869
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E27F96B0003; Tue, 25 Jun 2019 19:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB2308E0002; Tue, 25 Jun 2019 19:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C51CF8E0003; Tue, 25 Jun 2019 19:57:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6666B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:57:54 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d135so1149991ywd.0
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:57:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BYYmoTlsMAXHE1sdf2TkcUfIalvt5FU+r7Wng7vtf2k=;
        b=Uux/BwMfMm9Ktwl40kWBv+oN71RqGiLw9hm9HpATHBiYQMQwkFufCd+fkNsygkR7Km
         jMGsxqn2DmJX8t4c/Aybbap5D+vWey81bBZBhMmt/NAWz0oDDahrvThqbK0Ojl57wfrt
         oQKz79FFH38hiMVHdVCCzL6tL2BO3Ul5BFDqv2lrjjP6+j2MRoDw5GvaBXV3Apz4O2yt
         R2Q44xoXIlALRfmJwHz5sbSpOznfltDl/YwBlN92n/p22y4/Lb+AUfDhop+L3C+znqpf
         JIw9FsYHDTDht1BfoSsEQhfgLizdMrYfUW781dKkr6WKYyboqzLXC3fHUSotGbRXkMmx
         sc3A==
X-Gm-Message-State: APjAAAWwklo6ippb52X3AlcSpR+DTy3qPfc9W75h4RMtBihtFgtduVcL
	kv9Gk3oDq6r5QzxjbL9cDp3MU4m6FEW9tr6QOrppMGMUgYD2zsrY9ukRpmI+DeHfXiwoptVYuu2
	ChY8vuCfxF/bO9iWuA6JmIrsguJPAvmE5RufYKpik2cfX4ewvFFJZ5e76tsG7YAot0w==
X-Received: by 2002:a81:2596:: with SMTP id l144mr876920ywl.209.1561507074400;
        Tue, 25 Jun 2019 16:57:54 -0700 (PDT)
X-Received: by 2002:a81:2596:: with SMTP id l144mr876909ywl.209.1561507073789;
        Tue, 25 Jun 2019 16:57:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561507073; cv=none;
        d=google.com; s=arc-20160816;
        b=pvpLwF/bbsGBjjW/Gv70luDLXywpVG+fj7+VDKGGed3jdj5I/wY270zXCkn7CbdN3a
         ff2wGwRb/9yz+IrmeTfRPHGG7JY/GPKyAFrM8UvE6pIOjFE9P4EAJhGivcbjxov0jeh9
         hG5pCH0eFfsxLFtwIk0LEwFUe2gzmLay3vMe9oPz8ozVtu7yFJ8Y3JKKW2w5eWhsD/I7
         QdIST7WIKkiwUicREJNkSizRzyh9ODzVviHDVkb8cemvoexJCe/NyLQ/RwAUd6T7F719
         541TIqJrMiOq7lYz6rNtiyyHu5U3FoVnBQ7GI4SsuD15Yiytcle90P4Kzh0ulKudVbN9
         s+Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BYYmoTlsMAXHE1sdf2TkcUfIalvt5FU+r7Wng7vtf2k=;
        b=F/17fjFP+n6ACY65FbMArxB7kLd7tyZkHTyNybQOQ65GrMfgCqJGVo1h6ftfo1abbX
         cSHVjAQ+Ek73TkhqgJL3zZt6cvkpdaIALrRBlXgyX+fETPROIdE7qabqyq6KLKAXQCBp
         ZensXK3pLI8vGTtWeyq9iY6e9JbtXs4SBjtP+GbmBDtJnbt9kBbvRE7CqEsa/V7wvd+z
         uOn+p2XMZyWhclafZZS50FBqYfIYcX4Zgo/tLKdxEZTescChJ8W45Sfg0FTsHhlv0O9N
         Jsva08fAUOPHtheQleLGfMPLzVL07zjEROcgEJgLoui8hjJF0rVoVB1z+mqIzp3XRngJ
         /wUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bHr9RG0t;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q127sor6481916ywb.91.2019.06.25.16.57.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 16:57:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bHr9RG0t;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BYYmoTlsMAXHE1sdf2TkcUfIalvt5FU+r7Wng7vtf2k=;
        b=bHr9RG0tkfub5JlEPuSlccDNn2kaBl57++YE4B9BvBAfrk/lrYZ49HU1Eo9gNT3ehk
         fNU3tQP8gui8q9wB/h1Fc81T9JFeVcZUyl03XKjJ8gOzY53YIyIzh/i5zII6JgrWgqIM
         lkO3DVg7MWoytL4Eb8VJIzvW8QcRR10rlGa08CISiQVyfr2JSdtGwciaMXKI87B1ul24
         1PRqHKieYqB7Sdn81jUAtFn5JbY1GfrO71H4sWFwdVdgOE9Ns1kODIziZwkcUyqk4eHb
         Lull0e5SzkFSpJ4SxrKHhM1n+liVt/Q1fOL4ylNWFL6BIl1nlhx95K+44HpmfXZQO1Ma
         7Swg==
X-Google-Smtp-Source: APXvYqwLaw1k639FvVXfSfGs08cOnJCQGJfxpqhknTwehsMkT1lTu3zMHVWSGjAgN0vQtarw8VCOzDn0TuQCrm+B3mU=
X-Received: by 2002:a81:ae0e:: with SMTP id m14mr978096ywh.308.1561507073185;
 Tue, 25 Jun 2019 16:57:53 -0700 (PDT)
MIME-Version: 1.0
References: <20190611231813.3148843-1-guro@fb.com> <20190611231813.3148843-9-guro@fb.com>
In-Reply-To: <20190611231813.3148843-9-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 25 Jun 2019 16:57:42 -0700
Message-ID: <CALvZod7Z=q9YOGpWjv=EsORCy5dHAz+cDv=4qwD5V5xDv60QEw@mail.gmail.com>
Subject: Re: [PATCH v7 08/10] mm: rework non-root kmem_cache lifecycle management
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Waiman Long <longman@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 4:18 PM Roman Gushchin <guro@fb.com> wrote:
>
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
>         orig            patched
>
> real    0m1.455s        real    0m1.355s
> user    0m0.206s        user    0m0.219s
> sys     0m0.855s        sys     0m0.807s
>
> real    0m1.487s        real    0m1.699s
> user    0m0.221s        user    0m0.256s
> sys     0m0.806s        sys     0m0.948s
>
> real    0m1.515s        real    0m1.505s
> user    0m0.183s        user    0m0.215s
> sys     0m0.876s        sys     0m0.858s
>
> real    0m1.291s        real    0m1.380s
> user    0m0.193s        user    0m0.198s
> sys     0m0.843s        sys     0m0.786s
>
> real    0m1.364s        real    0m1.374s
> user    0m0.180s        user    0m0.182s
> sys     0m0.868s        sys     0m0.806s
>
> real    0m1.352s        real    0m1.312s
> user    0m0.201s        user    0m0.212s
> sys     0m0.820s        sys     0m0.761s
>
> real    0m1.302s        real    0m1.349s
> user    0m0.205s        user    0m0.203s
> sys     0m0.803s        sys     0m0.792s
>
> real    0m1.334s        real    0m1.301s
> user    0m0.194s        user    0m0.201s
> sys     0m0.806s        sys     0m0.779s
>
> real    0m1.426s        real    0m1.434s
> user    0m0.216s        user    0m0.181s
> sys     0m0.824s        sys     0m0.864s
>
> real    0m1.350s        real    0m1.295s
> user    0m0.200s        user    0m0.190s
> sys     0m0.842s        sys     0m0.811s
>
> So it looks like the difference is not noticeable in this test.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

