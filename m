Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBE69C4646D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86F42214AE
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:11:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XShNbisf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86F42214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 219F26B0006; Mon,  1 Jul 2019 06:11:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C9FC8E0003; Mon,  1 Jul 2019 06:11:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BA208E0002; Mon,  1 Jul 2019 06:11:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f79.google.com (mail-lf1-f79.google.com [209.85.167.79])
	by kanga.kvack.org (Postfix) with ESMTP id 9A31B6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 06:11:34 -0400 (EDT)
Received: by mail-lf1-f79.google.com with SMTP id a1so987801lfi.16
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 03:11:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N7LB99b1qzJUqx9SmCRa+EsWNHIydh4ATXZtXVbwfnQ=;
        b=ksGqIIuRWO1bE0XnR2P6pUVDlADtet06zAtQMV56Ih0TONUyTZIgV0kMOWKxJc7oFF
         3oASfLsSL6LXbLjhFSp/fGHkE7qi//ACij92su4iq9jMrwvBGGuGan1RyLFM3chWiSjN
         Giuc5pDS9Uxpt97oGO1/dqEVMm2yDRKLQwcvp9ljiB8uQXLiuuOGQd4nVSQ4hf0KHePd
         F68reBFP9DMg0DBGZ0mvaVWx0m2gobzmBquS8VA/GRiSQPByAVu+k7PzupZM+Ta3eqV2
         l9b0757QRdYAHfEtrclSrYO3Jz8J9EZ24Y/IUOUfVBVJP0ue74WG5U1YIo3s/+zi6txq
         wygA==
X-Gm-Message-State: APjAAAWcNwX+kBJ2f/XDtmURaBY4Li/4SF88E3rcykxwM2OA6KrxzFGR
	YWpMJhAHqAXFR13BGSkL2Mg/+K23t73xiG9iZ/NP/Qi471p7TNrXbeymvlWi3obNm493y2CyEZQ
	CvPph88VXSj0+CGx9MGJRn6Y1IiRc4WiuJnKT+qVteAN4QW3PAl8QVwVzv0ANuivlSw==
X-Received: by 2002:ac2:53a5:: with SMTP id j5mr11013733lfh.172.1561975893706;
        Mon, 01 Jul 2019 03:11:33 -0700 (PDT)
X-Received: by 2002:ac2:53a5:: with SMTP id j5mr11013689lfh.172.1561975892082;
        Mon, 01 Jul 2019 03:11:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561975892; cv=none;
        d=google.com; s=arc-20160816;
        b=rYWWjng3oZmZgJkF2vuX+y54Dw4W9cOhSTN/sxSvSKXeYOC29h3yy0o7Dq0NcJ+e8o
         WDAfBkQ7+X3RGdR7GZkaH7kKmwGlfICZMqbFBeDvkUu/exwJagsi+Ii4oYQoapQ6Wxij
         zGmvvuUgmKMnDCuz404neY0B8eNXCfTHoAKJBFRs/vnRPo5DtaP7uENnwNjodoEFQFze
         B5P/UKHgbuq9P2BqKe9dNBS1cQ0kovUbc6HxTSY7ELp3PW80Uli/8B10urJiU+ifmynG
         hXRY9zlaDc/01HhTarIpJyGy2d1quxL/p2rZl/GyBaWc8FrIiXyzuBeWy208Qq0b4FwW
         2dFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=N7LB99b1qzJUqx9SmCRa+EsWNHIydh4ATXZtXVbwfnQ=;
        b=eNwOrW7cYKEdVbAVWLzxt3BK8uknB9uqiPInY+Tbo+7jE9dqwKlEIjD2fml24+f7X/
         JeNqMd2xuRhdIWV0s29TAFU3FGMFHjOvZrwpXV88woI8XzlOAzFNkKyBgDXNf1Wxzxw2
         8TFrTjwdBVp0KWa+J76DGhHqALQRjKjTtt1UmkIQLxiXR0ENqQmYzMpiKal14QjPWQBY
         t3BCogiAg5SJgBXnx4V54j5pk/j8VEav6geEv9iyR/PsVM5KNu1YjCGYZQUOOGP+Xeuo
         l0Etk5np3VKdNzTy6M9yJ+sCuzXiQdP8uV1lyj1EL/BwjoPQ/nR7kgb/g4MWl6Fp1usw
         uW5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XShNbisf;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w3sor2215346lfc.4.2019.07.01.03.11.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 03:11:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XShNbisf;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=N7LB99b1qzJUqx9SmCRa+EsWNHIydh4ATXZtXVbwfnQ=;
        b=XShNbisfpbRo+ipmO1lFLAt44cpIs6OV3XEjkyB4LWB5d9CXKYMgR/cfL/ZbGzB2D3
         5NY4e4L+juq3egHqXrmn6gkO9p0s6EEhbd+f4M0l3pTspJmfyPyC2CV5q44g8NBpSLT/
         mkHl1KFrzH+nDkpKXxBbrMF5dtyXsFff9heHYAnRqcQN8LynZ2yOjDJYcPDINxra0sbf
         M9hF8n3Ja7XFK0qsbKKBSZMszK7fZQv2pM3Eoq/6tt8oUsxgteUa8iQ3VCHHUgqiUZOt
         YlhWOza1dIMag9/ajlN+Ioo3gAbP8JalhGidMIPsvUUW3yoVZAkUwJll1tbCqxNWjfKc
         KE2Q==
X-Google-Smtp-Source: APXvYqxGMSKGWwcnh0QtFlSYyKGfsaUplzIpRiz8atO/XLiTZSSU6i+tSZ6IyKASWltGYakGfSYNBg==
X-Received: by 2002:ac2:5e9b:: with SMTP id b27mr10418308lfq.45.1561975891456;
        Mon, 01 Jul 2019 03:11:31 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id j7sm3536968lji.27.2019.07.01.03.11.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Jul 2019 03:11:30 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 1 Jul 2019 12:11:21 +0200
To: Michal Hocko <mhocko@kernel.org>
Cc: Pengfei Li <lpf.vector@gmail.com>, akpm@linux-foundation.org,
	peterz@infradead.org, urezki@gmail.com, rpenyaev@suse.de,
	guro@fb.com, aryabinin@virtuozzo.com, rppt@linux.ibm.com,
	mingo@kernel.org, rick.p.edgecombe@intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/5] mm/vmalloc.c: improve readability and rewrite
 vmap_area
Message-ID: <20190701101121.kyg65fbcd7reszk7@pc636>
References: <20190630075650.8516-1-lpf.vector@gmail.com>
 <20190701092037.GL6376@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701092037.GL6376@dhcp22.suse.cz>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 11:20:37AM +0200, Michal Hocko wrote:
> On Sun 30-06-19 15:56:45, Pengfei Li wrote:
> > Hi,
> > 
> > This series of patches is to reduce the size of struct vmap_area.
> > 
> > Since the members of struct vmap_area are not being used at the same time,
> > it is possible to reduce its size by placing several members that are not
> > used at the same time in a union.
> > 
> > The first 4 patches did some preparatory work for this and improved
> > readability.
> > 
> > The fifth patch is the main patch, it did the work of rewriting vmap_area.
> > 
> > More details can be obtained from the commit message.
> 
> None of the commit messages talk about the motivation. Why do we want to
> add quite some code to achieve this? How much do we save? This all
> should be a part of the cover letter.
> 
> > Thanks,
> > 
> > Pengfei
> > 
> > Pengfei Li (5):
> >   mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
> >   mm/vmalloc.c: Introduce a wrapper function of
> >     insert_vmap_area_augment()
> >   mm/vmalloc.c: Rename function __find_vmap_area() for readability
> >   mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readability
> >   mm/vmalloc.c: Rewrite struct vmap_area to reduce its size
> > 
> >  include/linux/vmalloc.h |  28 +++++---
> >  mm/vmalloc.c            | 144 +++++++++++++++++++++++++++-------------
> >  2 files changed, 117 insertions(+), 55 deletions(-)
> > 
> > -- 
> > 2.21.0

> > Pengfei Li (5):
> >   mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
> >   mm/vmalloc.c: Introduce a wrapper function of
> >     insert_vmap_area_augment()
> >   mm/vmalloc.c: Rename function __find_vmap_area() for readability
> >   mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readability
> >   mm/vmalloc.c: Rewrite struct vmap_area to reduce its size
Fitting vmap_area to 1 cacheline boundary makes sense to me. I was thinking about
that and i have patches in my pipeline to send out but implementation is different.

I had a look at all 5 patches. What you are doing is reasonable to me, i mean when
it comes to the idea of reducing the size to L1 cache line. 

I have a concern about implementation and all logic around when we can use va_start
and when it is something else. It is not optimal at least to me, from performance point
of view and complexity. All hot paths and tree traversal are affected by that.

For example running the vmalloc test driver against this series shows the following
delta:

<5.2.0-rc6+>
Summary: fix_size_alloc_test passed: loops: 1000000 avg: 969370 usec
Summary: full_fit_alloc_test passed: loops: 1000000 avg: 989619 usec
Summary: long_busy_list_alloc_test loops: 1000000 avg: 12895813 usec
<5.2.0-rc6+>

<this series>
Summary: fix_size_alloc_test passed: loops: 1000000 avg: 1098372 usec
Summary: full_fit_alloc_test passed: loops: 1000000 avg: 1167260 usec
Summary: long_busy_list_alloc_test passed: loops: 1000000 avg: 12934286 usec
<this series>

For example, the degrade in second test is ~15%.

--
Vlad Rezki

