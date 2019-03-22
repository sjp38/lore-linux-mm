Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A5E7C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 19:39:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B578A2148D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 19:39:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="iT0HBMtB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B578A2148D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36F2A6B0005; Fri, 22 Mar 2019 15:39:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31E886B0006; Fri, 22 Mar 2019 15:39:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E6F36B0007; Fri, 22 Mar 2019 15:39:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEA246B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:39:32 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n13so3393236qtn.6
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 12:39:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=+QFmd+qhN2DLA1/sywGPwInOJrjDW1Q9BEXsX4YZ2II=;
        b=ZPSO74OH7NaVcPC0m1WJ6NG3Mq+i/xrbI1szrwKg9XWLWMY9MemK/Bhbwew7IsNeCL
         xSgxkLVUIuKxBH294p7WSrwUjAmgt/T3TtmcWFDyd8MW5VwZIpDGdD72ERCe+nSTAXWe
         SkvpXu7eRupK1nr3zctMIksIbq2gJ/1vV0bXYfWFy63/LESAVukZRvajKTtZlwQITetx
         9CYBbgRmoTTxxhiQc7uABqRHhHZl5zSautuM7OXyz1nQK8lfD6+gin7ZH4tkhKG63mt7
         cMdVTZn4Ye3tYw3BRy9yRDHffq7NIgJ48ozv7Hvq4npPM0c4MidvGHgLnMDxIyJNeOJW
         j+1w==
X-Gm-Message-State: APjAAAXVkmVOG1zt4GD6ChTQqvNtrJgVArTCFlLX+WnVVWAkE/CsbolO
	j0CSbwjxehmrjmyEMwGzpo9O7j1AqykNf/nIs0TFWSGMk8AnKfq8ZA29j+MiVlQ711dBJh1tV0T
	UrnTRktNkpkwOa8EzIHRMJfeggkzqkSYGV4UUl4Q9pz2SXK5C3By0v+5lVaRvM6Y=
X-Received: by 2002:ac8:2d02:: with SMTP id n2mr9683614qta.229.1553283572620;
        Fri, 22 Mar 2019 12:39:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnAznSkvaoFpR3xbm4cxPm+ofWAFeSfMr/jjo0BAqqKLsfowIc5aITMRRP0ngXsUPlRNoX
X-Received: by 2002:ac8:2d02:: with SMTP id n2mr9683565qta.229.1553283571943;
        Fri, 22 Mar 2019 12:39:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553283571; cv=none;
        d=google.com; s=arc-20160816;
        b=Hijdj3RBniYUwefBPI+zg22EoERrIw05Exc0+IylGkU4JxJ8pNSpFNJ5YDaDImHnLA
         toUb8lbTI9zv1inDyEFV+gW3rakz6kO1Jh5bI26qUe66UwOnMNQYYgEadWPto/tMyeeK
         mJhXaGINK+t6TZwjccdh7dsB+U01KiUMEVaXCPC2PUPoKByt6B9//2KXfXak5hbuv0vk
         trJbCdBRqgP7BqcU1PHJ/8+DCylcPm9YOUHxfqEDA7cAe6W7uXFqecbjo+atdr3uA6qz
         wF7XiQrwXyj2zPZkP3fYOTNjxJz7AeHxNCUH4j1lIkb7cEikeg7ISyH4nMDIHCQsdQHL
         bmow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=+QFmd+qhN2DLA1/sywGPwInOJrjDW1Q9BEXsX4YZ2II=;
        b=Kkn8Zfqv6ZyT3unoAAPtAi51Usg4alXOaLHA/rixSQeb79MmIhapqvI3IjJThh6VNu
         c3uSRvGw+uXMBVn1SrJeudwDAmUvV87dwUi6tY6zwUc8Z+9WC0XFpgArvYpv/n7OdIBJ
         4+nBR1id1Ze2bhV2mHx3DAFJ5SYBj/l7HvDRsEVYnjOCMOWgcM2M8NJ9XQkzA7l+ydkN
         AMkOYvdVzg4OS8NorGNNGcbXfPxNMf4od/bVG6VFk+IX5a7mPV+K0JmG3Gz8kP48LtXW
         AZFNn3rwoPVhkPR2pKpn9SNVJ/l09pmqO7c5wNnDtZFle98UyAR1Ixl4/eG2WDtIrIr0
         5t6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=iT0HBMtB;
       spf=pass (google.com: domain of 01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@amazonses.com
Received: from a9-30.smtp-out.amazonses.com (a9-30.smtp-out.amazonses.com. [54.240.9.30])
        by mx.google.com with ESMTPS id p67si650813qkd.272.2019.03.22.12.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Mar 2019 12:39:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@amazonses.com designates 54.240.9.30 as permitted sender) client-ip=54.240.9.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=iT0HBMtB;
       spf=pass (google.com: domain of 01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553283571;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=+QFmd+qhN2DLA1/sywGPwInOJrjDW1Q9BEXsX4YZ2II=;
	b=iT0HBMtBFw2zX7vPdC/3Hsd9GGDeJyPy6RlxeEJUJszYMDjDulBgegdH876HD3qC
	BOgjqXiznIZnV3+Sj6z/nBaQCINjevkXajnbsdePLIenCSkdZj3ReRNlcgKJsKNchHb
	LLL7D9EhkY/3zv0B+S6iFEINleSK1wksxGKy3K9Y=
Date: Fri, 22 Mar 2019 19:39:31 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Waiman Long <longman@redhat.com>
cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, selinux@vger.kernel.org, 
    Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, 
    Eric Paris <eparis@parisplace.org>, 
    "Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
In-Reply-To: <93523469-48b0-07c8-54fd-300678af3163@redhat.com>
Message-ID: <01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@email.amazonses.com>
References: <20190321214512.11524-1-longman@redhat.com> <20190321214512.11524-3-longman@redhat.com> <20190322015208.GD19508@bombadil.infradead.org> <20190322111642.GA28876@redhat.com> <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
 <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com> <93523469-48b0-07c8-54fd-300678af3163@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.22-54.240.9.30
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Mar 2019, Waiman Long wrote:

> >
> >> I am looking forward to it.
> > There is also alrady rcu being used in these paths. kfree_rcu() would not
> > be enough? It is an estalished mechanism that is mature and well
> > understood.
> >
> In this case, the memory objects are from kmem caches, so they can't
> freed using kfree_rcu().

Oh they can. kfree() can free memory from any slab cache.

> There are certainly overhead using the kfree_rcu(), or a
> kfree_rcu()-like mechanism. Also I think the actual freeing is done at
> SoftIRQ context which can be a problem if there are too many memory
> objects to free.

No there is none that I am aware of. And this has survived testing of HPC
loads with gazillion of objects that have to be freed from multiple
processors. We really should not rearchitect this stuff... It took us
quite a long time to have this scale well under all loads.

Please use rcu_free().


