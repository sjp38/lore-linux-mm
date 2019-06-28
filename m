Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DDFCC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 216072083B
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:16:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ahnblySt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 216072083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B35D46B0003; Fri, 28 Jun 2019 13:16:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC1478E0003; Fri, 28 Jun 2019 13:16:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 960CC8E0002; Fri, 28 Jun 2019 13:16:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71A896B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 13:16:27 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id j128so7094313qkd.23
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 10:16:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=X/aiZ9J+dd4UJLcrpdr3hoLcNRw4Si2ePjPQfQ4q8YM=;
        b=sUg61MUC7GDsUy45sx7VX1TKe3dDzyjhX7c1EFuXFZhEkCFE8au9yCq8Z6tq0w8Y4g
         uHJFRjhaST+sAzisTxJKuK9U7Wt0ofTUzlVmYzQLWpwXH/6wjzM44931Q7dEwFDmpFwN
         iGtMk5ABGXIe+IcHIy69SpFvzyGI/ufO5kC8UrJV9a970fFlsHJKxqxvKNmgRU/jYn5W
         M85ZFKOyPlteu7zn6fIhHtkOjXc4c9Kh1wsD+ct4jmlbV7p+h34YCeOOik2r3h9TuFBe
         kq2Eu0K1gSfwqxAUsfJoXS9XCHRm0pVPfOzjgY9VYfzVdkopk864ZocFAVE7ZjKrdXlR
         3/CQ==
X-Gm-Message-State: APjAAAVXS1vsfDpmRtwAhsGZklCOZpZSZgF2ucgaATTq7h5K9bUD1ve/
	xg2uUf5iWgTReRcUERBSE4sJ4N/2BPhMaFlF2E7x6bn4S4AeR1QOmYtRulC77rINi7jvUeob2TX
	rXNA0FYp/Kppj3NGUHE0Ziz6G06DlanLQ+XXKU14MBCdLZDTOa6VDGToQQcxmBuYBuA==
X-Received: by 2002:a05:620a:1270:: with SMTP id b16mr9460242qkl.333.1561742187223;
        Fri, 28 Jun 2019 10:16:27 -0700 (PDT)
X-Received: by 2002:a05:620a:1270:: with SMTP id b16mr9460203qkl.333.1561742186765;
        Fri, 28 Jun 2019 10:16:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561742186; cv=none;
        d=google.com; s=arc-20160816;
        b=RPQd23dxKnyjgCUNwjqDEkf3mUXAGmwL2YdW47E8ltJ8erU2G8A3XrHWhwjRkbuetu
         3OLPjwHD+r00UulicjZlGXOZT+Lwb+vUJVaUImXZHaegYf53n18EPrUCR1LF5+ooU4Uk
         TAh+oV4KLZQOBoLMwrYTp2bmJybLOJC5PCd0t4NYYGW7ZGL3xIvBJ/VuHmLXSrnNZiFh
         YTHT/lY+AqgOtZNd3oS7efcXi2dQf/jfRBSLOOD+OoSDm1JbKgkrkbfWmGXhMbiGBvxs
         v+AUA01lIo8x/9qqKu8rIVUD42AVjdphKEXa7Mcu4rZg9jQXXnNqxbtQbb36DyrHfufz
         7GfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=X/aiZ9J+dd4UJLcrpdr3hoLcNRw4Si2ePjPQfQ4q8YM=;
        b=feZAf+QwFPGYxSHpgr1606dDywKjFlC0VaY9PjKEfQv9k5keg7tSXsEWafHngbSoAN
         yizeu6fw7Xzb0gNNfIjMEMxUDgRCq+WpdXi6Yzq887PPZJLijPCognyy8wHn5didvSpP
         mpoPHs2u69iBCjj296c5Q3gwYmSKgKu/hCHb1eMrrdumFqJL3U9RIMuIa8uMvQag21VC
         01S8a7sAB9XhhatlKJXske0BYbspnstVyUk2tLv7W/pxs+dn6U20rY4mXNjTeQfuggDU
         BuBl3dNQ984h3CYyGoKB+Z6fUsZE5y/jApWPwCrZyOJkyI9qJNPWpH3jwK/HcoVocQ2f
         40Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ahnblySt;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u9sor4193696qth.4.2019.06.28.10.16.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 10:16:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ahnblySt;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=X/aiZ9J+dd4UJLcrpdr3hoLcNRw4Si2ePjPQfQ4q8YM=;
        b=ahnblyStPij2rtGufd7uEL9kTluJbQDHGS1iKvW73t2ebo3vRNn8FTuQKgazM07J6O
         +wXSCQjEJyVN+Z3gV5TMXtCb4Y0BIUZC4KxjAK9eozvCWn7wRcEL7pPsnDG3O9sFCOtj
         7mtNmpZC6VCXYGNzMz40aPZe0km5xgpLwl3cJ2tu5+2EK3h7m9alVYStSrdTVHqHMtp8
         JjPRmJwPCsm/WT2+xKeeXM+QzweX3GmM5GeVUw98UEEx+NBdcny3Wqp02cGUnsp03S2w
         3znGOn57MuwAlyVtWFo05byzrDA0uYw0CMUTrbFQ7ORqxyJYHci8YsBH/OSm/emVhCjd
         KvHg==
X-Google-Smtp-Source: APXvYqzeD7ol/qvSpnvEU83iiMeuVww8kn8c1trrLyIBjpx7kD3KA1jNvtOoaae97XqoObXYba1r6IpVH1Cd2BuViC4=
X-Received: by 2002:aed:36c5:: with SMTP id f63mr9236038qtb.239.1561742186465;
 Fri, 28 Jun 2019 10:16:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190624174219.25513-1-longman@redhat.com> <20190624174219.25513-3-longman@redhat.com>
 <20190626201900.GC24698@tower.DHCP.thefacebook.com> <063752b2-4f1a-d198-36e7-3e642d4fcf19@redhat.com>
 <20190627212419.GA25233@tower.DHCP.thefacebook.com> <0100016b9eb7685e-0a5ab625-abb4-4e79-ab86-07744b1e4c3a-000000@email.amazonses.com>
In-Reply-To: <0100016b9eb7685e-0a5ab625-abb4-4e79-ab86-07744b1e4c3a-000000@email.amazonses.com>
From: Yang Shi <shy828301@gmail.com>
Date: Fri, 28 Jun 2019 10:16:13 -0700
Message-ID: <CAHbLzkr+EJWgAQ9VhAdeTtMx+11=AX=mVVEvC-0UihROf2J+PA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
To: Christopher Lameter <cl@linux.com>
Cc: Roman Gushchin <guro@fb.com>, Waiman Long <longman@redhat.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jonathan Corbet <corbet@lwn.net>, Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, 
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 8:32 AM Christopher Lameter <cl@linux.com> wrote:
>
> On Thu, 27 Jun 2019, Roman Gushchin wrote:
>
> > so that objects belonging to different memory cgroups can share the same page
> > and kmem_caches.
> >
> > It's a fairly big change though.
>
> Could this be done at another level? Put a cgoup pointer into the
> corresponding structures and then go back to just a single kmen_cache for
> the system as a whole? You can still account them per cgroup and there
> will be no cleanup problem anymore. You could scan through a slab cache
> to remove the objects of a certain cgroup and then the fragmentation
> problem that cgroups create here will be handled by the slab allocators in
> the traditional way. The duplication of the kmem_cache was not designed
> into the allocators but bolted on later.

I'm afraid this may bring in another problem for memcg page reclaim.
When shrinking the slabs, the shrinker may end up scanning a very long
list to find out the slabs for a specific memcg. Particularly for the
count operation, it may have to scan the list from the beginning all
the way down to the end. It may take unbounded time.

When I worked on THP deferred split shrinker problem, I used to do
like this, but it turns out it may take milliseconds to count the
objects on the list, but it may just need reclaim a few of them.

>

