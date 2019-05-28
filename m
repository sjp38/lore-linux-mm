Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8EF0C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 20:11:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF52B20989
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 20:11:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xi1rvf82"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF52B20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 401A46B028D; Tue, 28 May 2019 16:11:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B1AF6B028E; Tue, 28 May 2019 16:11:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A16C6B028F; Tue, 28 May 2019 16:11:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id B2BED6B028D
	for <linux-mm@kvack.org>; Tue, 28 May 2019 16:11:08 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id f15so3578339lfc.10
        for <linux-mm@kvack.org>; Tue, 28 May 2019 13:11:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=IhQcOeMQDDyAontCK40/Nbm1mljx7ySDbK1mzDX9hII=;
        b=WH8s4lDQqfsKiSTDI/IHeDYW9kTiXpH9K7/wKK5lkZEWwRyJQB5Yi3C9YzV3IpUEY2
         kf1Tdn677b/vVu+FFp3s/NGBYDQVjZOn1B+3bxzTXapm622muyFHGFp6zhhGaBSK5qC2
         bmWNpvTOys6FM7p4t+5RRnI9bg7/MizrSM9Y5ImYI9LOmmZ4Xb6DnryHUkLnADSp/Wmz
         eHOmx+RS/D2439330OpnLKKTGljVEaaFopxgbrkjEdbAAspVIzh1OPAiS34dMR0LO8uV
         0p37AIBhYGGeidt01P3+9UOoI8eiULdXdxEJM0cxxphOYPp/2P+/7So8ZAXwyBZJfz9A
         RUnQ==
X-Gm-Message-State: APjAAAW0R9U14+IrrUO38umiXmTl4uGPDtwzOJjpN59gc2ZP7Jk/3aJX
	gu3Enrg9uPzx7NC2F5waTm9PcTZQuT9KrDrBqSS36VJJfAx66MjMlt547xpeeShlGFuFJBygGhT
	inJ0D1+O+cg+ERQRyF89ErgkDAxyOdNPn6bFg086skd++GLkPqJO72UVdvTdkioII8A==
X-Received: by 2002:a2e:3a1a:: with SMTP id h26mr14730930lja.156.1559074267837;
        Tue, 28 May 2019 13:11:07 -0700 (PDT)
X-Received: by 2002:a2e:3a1a:: with SMTP id h26mr14730890lja.156.1559074267023;
        Tue, 28 May 2019 13:11:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559074267; cv=none;
        d=google.com; s=arc-20160816;
        b=FxkbP18GrZpULRQmF75rk2kP5DJCA9RY0ciyjiyfNmVQ7eaE7aJ3p2ZBvM2U7OXjtO
         HcuHZeKA5awx4lfv+v+s+OkWd5/1eM4EfXv3LS0IJ1t7x03C7ddv1Q4EDtEcBNMEddX1
         sZVy7XeVg8i4dgwMxVdWJDEfGeVjzj0qvK9MDtt4xQ/oWd7nS6X0zGYujeIK8mwEE/0P
         EqGZVKLk57vN71H/ILVHqJ+aT6/ORoMyo6+07zAnA5uJHYY5RyQt9o9DozXvjUkbyMjX
         YfqGoaufSZpXVbWXa0ZPSOIVvJxYJYNHIpEZ1nC8mYALVGok2O7CWHacYEzCumOLboWM
         H50w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=IhQcOeMQDDyAontCK40/Nbm1mljx7ySDbK1mzDX9hII=;
        b=AV0T/6JMLNGmAQopbV+hfEMfo691K38QLF8lvG3C/wiha06bj32bKKLfJR3qMToNWn
         Cr0YGZEjcCCeja/E3vXeAehtT+yXY2uO1Fr6NzfNc1ay1703tyx+E7oPbHEwzUcnt9UN
         zIMhY5REvuLT/lJz+WVuUfcJvKnm5JAUdo2wwZY6u3vGCIhLR+xlBFa+U7Qv5Gnesp3n
         GAES1wA6Owpe4t7lQXOkFAkBplPG9qFnPu6QuKV1GeiDGDptogJiCe158UmKHDnkwz1Z
         eZjQJWTzSnyl1vH7mr3qV9xuH8PHVUipsQRSwqUuRRp/m6hVarfFtw23nOsoRVwYR8DU
         Dnvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xi1rvf82;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t26sor4030705lfl.8.2019.05.28.13.11.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 13:11:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xi1rvf82;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=IhQcOeMQDDyAontCK40/Nbm1mljx7ySDbK1mzDX9hII=;
        b=Xi1rvf82R+sAQrYfabSK06Oc3zrxz8A4e+xmdG9AUs3GEvmrywT07vu1Cdbwq/n+xC
         dhTgk/se4eR4Ig+rHsTTHDJlcN63ODXw271T4KGgt4YkjXCyvu8qSH0f0fXf/g6urI3y
         c4yPQrnqmATMPqTEAeV8o+YdaFcJEC9ZveudH3c2ybsmgtfwNbKhVpH3jMiM2DCCRFZF
         Rl7v4N5R1yF+cGs9dD20FId6Cm/FCykxQSf4SR4+8tIu8TYJULxXWzwkhGQ8yvwSl9sx
         gENvr/QOA/o9+vwBi3YD8jXXztGw2Fmzgx0nKc79w9lc5uejD1VHiOJ/QV41g+10ChlG
         +K/g==
X-Google-Smtp-Source: APXvYqxbtuiphdr7uOzm2RzAxCso5Xl2QTmkl8kXwKEa4vRk2eXXO+l8K2YzCgGuVBJOPQZ/zhBFOw==
X-Received: by 2002:a19:f601:: with SMTP id x1mr8477797lfe.182.1559074266579;
        Tue, 28 May 2019 13:11:06 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id k21sm3592869lji.81.2019.05.28.13.11.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 13:11:05 -0700 (PDT)
Date: Tue, 28 May 2019 23:11:02 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 6/7] mm: reparent slab memory on cgroup removal
Message-ID: <20190528201102.63t6rtsrpq7yac44@esperanza>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-7-guro@fb.com>
 <20190528183302.zv75bsxxblc6v4dt@esperanza>
 <20190528195808.GA27847@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528195808.GA27847@tower.DHCP.thefacebook.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 07:58:17PM +0000, Roman Gushchin wrote:
> It looks like outstanding questions are:
> 1) synchronization around the dying flag
> 2) removing CONFIG_SLOB in 2/7
> 3) early sysfs_slab_remove()
> 4) mem_cgroup_from_kmem in 7/7
> 
> Please, let me know if I missed anything.

Also, I think that it might be possible to get rid of RCU call in kmem
cache destructor, because the cgroup subsystem already handles it and
we could probably piggyback - see my comment to 5/7. Not sure if it's
really necessary, since we already have RCU in SLUB, but worth looking
into, I guess, as it might simplify the code a bit.

