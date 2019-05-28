Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C532FC46460
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 18:33:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B69C208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 18:33:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JdETCGK0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B69C208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13E1D6B0289; Tue, 28 May 2019 14:33:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C7256B028A; Tue, 28 May 2019 14:33:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF8956B028B; Tue, 28 May 2019 14:33:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 898A16B0289
	for <linux-mm@kvack.org>; Tue, 28 May 2019 14:33:08 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id h1so3946163ljj.14
        for <linux-mm@kvack.org>; Tue, 28 May 2019 11:33:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=/dxRboK00I5JVZJIcKIh8lDmjqTZ8vT2RGIZXym9hs8=;
        b=WYK4Q8kynD2wkuWEhQJkrDPrzo9yIb8RHXgIv22qzsLMi7TpMnUHWJvzKR3jzqyu8d
         fQaTk4ha64N6UV6l3dbejnGxLdIkoMvUCP21Hfr7r9Wlhyqh9CGEUx6xxFHtFKoxYn7t
         l7IqTobMhWech4kRYE+Tgpeqe6SGs5ntgA47hgPnqn2l6FQ1uyNy1TiEnlLtXKcY0m2Y
         3/LeUjjXkHuj+xQKABVQrNAXLaIyE1kXa8PGZx+N13F6nD2+DH4TaJnvhCspkq22C9an
         gaI8Lh7CypZ/MNFQsLTUf29kWlOsTvzuGveLI9nSHCkjsUl19NMCRkuKXG2R+vLVF66p
         roSw==
X-Gm-Message-State: APjAAAWFs8qzfRqeQlOrtDppeeoR0umOqWowpR6EHFgo94T692Clr5gV
	31ebZ/8AlLsNLpISdb68EM1nMb6/h6DJk6vrjUo55SCdBoLwF7E+BXtX5I+gH0RbCKV52zqk6vk
	kyAoOAEWm+VjS7NsBygN2Q3xWMnCakokcKz216mY0J9H/IvUzZhYqnRDEJ4haEMQt9w==
X-Received: by 2002:a2e:99c3:: with SMTP id l3mr16626212ljj.73.1559068387616;
        Tue, 28 May 2019 11:33:07 -0700 (PDT)
X-Received: by 2002:a2e:99c3:: with SMTP id l3mr16626163ljj.73.1559068386541;
        Tue, 28 May 2019 11:33:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559068386; cv=none;
        d=google.com; s=arc-20160816;
        b=wYdxl/xB5lIN2ETSQWtDOXkmIF9NpIIAIVYbXBBRbLeBIf95BuRP9yvXFqvERG7e41
         c+Gpm50wTL3nFtKBwu8vms2pfVZckUPom+v10bZDo+7MiyahwDXKkjLAnyK7B0WIxPRI
         ejEFBMfOXDa7Gws42pfXFTrqstEcyM9U5xynpfYTLJeqvWundOehIx5AJNnJy8cow4vx
         p5jNS9P+7SuhDGONSvjpaYwammv+Gc/FEdSlHlT0lhJ6nGLYKwR0qjHppI3lw8Nn/nfN
         EMLFoRP2R6Ag90O6ZrQ68GmednTK1keZmZ/0eHWSimfgXtIi/6+2FBz0VXqAq+0d8d2X
         l68g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=/dxRboK00I5JVZJIcKIh8lDmjqTZ8vT2RGIZXym9hs8=;
        b=bkNvypxZfQ7F86V5w8ft7ZBm105ttaamdnh1FQz+ld+1lafIGZrjXGouptqBSls7CU
         Sp202nviNKOZ4dEuYbCa0gKmnRmPfp7j9B03Dff/I+2KdabaMO/FaTuQs5uX8bS3qOWH
         YSlNQ7UTGE6PtMwdpF9hI5Q4BxEfOX2JfVdQc5O2pH/Ug9Ms/IVo7CrUXArc0H2JQKJK
         FbYdorLMEfpu2skqrdeAE9bRj3jbQfmE00kXyE38qLfdOdBsJNHkVj95toqEEnJtD1oE
         JKWtd/iOXOiIYs/Ul45AU6fqpGF9gjPJYSHf1h6VVP+52djqkaFmq5u3T+L4mMFMNw9B
         0Lvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JdETCGK0;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor7848860lji.7.2019.05.28.11.33.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 11:33:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JdETCGK0;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=/dxRboK00I5JVZJIcKIh8lDmjqTZ8vT2RGIZXym9hs8=;
        b=JdETCGK02W+TtswFGWYTMmY9WIEyBXPpCljaIU/VvB/d3DyEtFWnP0lJVxjUjx9TD+
         BbFimxaiEpjpXaitfVH8KM8TBEOsn6oSsKdEWrPjq9D15Ew99jozw+GsV/lZqrVVZ0bd
         sGtow18Jv93Jk3c4kkSM9BZ05m3scy1imL1EdiSpaSjWhIrIPyNB9w8DdlCdVlnDOZNn
         KB5glui+lV+DZKpPu++CN6VKlXQmcVFXpxLJUgk52DMVAvzV1zTNcKZuZuMlzrMfr+zo
         qH7zlgas8ajm6z/0f37WMEh9ITFodHk5tXZpvMdRGXtAceFsYcaEo3ESqN2B34xySD+d
         KVXQ==
X-Google-Smtp-Source: APXvYqy3s9q75FdgW1jA17eTPuwlMKdHK6SG0NcuvVUvEqKB1BuEK4FqNNQLezmX/qt3sQkeKbs49Q==
X-Received: by 2002:a2e:9193:: with SMTP id f19mr24449382ljg.111.1559068386280;
        Tue, 28 May 2019 11:33:06 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id a7sm171218lji.13.2019.05.28.11.33.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 11:33:05 -0700 (PDT)
Date: Tue, 28 May 2019 21:33:02 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 6/7] mm: reparent slab memory on cgroup removal
Message-ID: <20190528183302.zv75bsxxblc6v4dt@esperanza>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-7-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521200735.2603003-7-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:07:34PM -0700, Roman Gushchin wrote:
> Let's reparent memcg slab memory on memcg offlining. This allows us
> to release the memory cgroup without waiting for the last outstanding
> kernel object (e.g. dentry used by another application).
> 
> So instead of reparenting all accounted slab pages, let's do reparent
> a relatively small amount of kmem_caches. Reparenting is performed as
> a part of the deactivation process.
> 
> Since the parent cgroup is already charged, everything we need to do
> is to splice the list of kmem_caches to the parent's kmem_caches list,
> swap the memcg pointer and drop the css refcounter for each kmem_cache
> and adjust the parent's css refcounter. Quite simple.
> 
> Please, note that kmem_cache->memcg_params.memcg isn't a stable
> pointer anymore. It's safe to read it under rcu_read_lock() or
> with slab_mutex held.
> 
> We can race with the slab allocation and deallocation paths. It's not
> a big problem: parent's charge and slab global stats are always
> correct, and we don't care anymore about the child usage and global
> stats. The child cgroup is already offline, so we don't use or show it
> anywhere.
> 
> Local slab stats (NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE)
> aren't used anywhere except count_shadow_nodes(). But even there it
> won't break anything: after reparenting "nodes" will be 0 on child
> level (because we're already reparenting shrinker lists), and on
> parent level page stats always were 0, and this patch won't change
> anything.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

This one looks good to me. I can't see why anything could possibly go
wrong after this change.

