Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9001C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 896802084F
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:05:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dVUMq2GT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 896802084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3ABE16B000E; Tue,  9 Apr 2019 10:05:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35BF46B0010; Tue,  9 Apr 2019 10:05:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24B386B0266; Tue,  9 Apr 2019 10:05:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0483D6B000E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 10:05:06 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id q203so2665681itb.2
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 07:05:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=b+cICRm86CSGIqdtgn80b09rxrmXqaSqq0j2KAMz0JU=;
        b=QVf1yzWnqHf9PTrBnkEJC7B7GfDrAh4j5QwnixGShv4LxRtYAsO4VzQ3t02J/AcGYm
         SS300Y/ZQ5sanYsGrnT2NWO4I7qg79MH2KpRhm4MB90gyZFINFmo2LFwXwugBk+bmTPy
         2UqQd3mfBm5unKX/OIDoacj/YiocnLBXIp8P7RKmwptlqpPXUeUeMtOA6fgifgVCehba
         7TtRTcy6SfcTlvLnzWy3KvwAOqd66S68Mz0pPsWcocBZIom4u+GVRhdcW9L+0GucB/cu
         VU6U7cF67EZUZcMTTQZK5MbeEEB5srDAEyjZchvvR7lw/MQavs5hQt25Ntrqyte72lSf
         dovA==
X-Gm-Message-State: APjAAAXzk/AU+XJEpm0Ut+s3tfEAPWLsHD5OaB7fcwB8mMnKmXwhVMoT
	ZVF61eqEq5N6WuYnqNt45rYRqB56AGw0QlYWbgYhEnKPWlYrSGytgYRu/7YLVfqJkU5mIlqEkHY
	rV6b5xDg75k6BRw+ERjOJXLsyDEY3pWe+oC9C01QmfDhA1W2sLd8aQsnLVL6w3ioa0g==
X-Received: by 2002:a24:4523:: with SMTP id y35mr26288756ita.153.1554818705735;
        Tue, 09 Apr 2019 07:05:05 -0700 (PDT)
X-Received: by 2002:a24:4523:: with SMTP id y35mr26288701ita.153.1554818705114;
        Tue, 09 Apr 2019 07:05:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554818705; cv=none;
        d=google.com; s=arc-20160816;
        b=nLVEZHO3MUbaF/8/o4Iojs6DhwN+MZPhxsE3LGFQctUJMNphaFu1MhrSfj090yX7iF
         t1A25lTHbwpbkckxk8PHklTndKT/CVHkU0LB/pLwQdT4OR2h2TKZ0CgwWB0KEHcju680
         PqDuf6WS+y2uQqO6gUEGrzAy8Zlbi1KqLIG1/9CQTlLsOcc7EeEokVmpmBQD9PvxUx4A
         D1Z2hOZp6bL8eoqaaVrufvsU6D4V27CYuiZA2jkdoxL/UPiiGe9mKNmTDWkZcTZro5Nk
         bwmDiar0eqDxszt4qoyhkXag9th9YjqJb4thRLE4wXbN8NH2DmUjGxDqWkpeaHbMv+MG
         ab1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=b+cICRm86CSGIqdtgn80b09rxrmXqaSqq0j2KAMz0JU=;
        b=MyEm6EgD8ETZeQzP9acFK7YSk4htU11Mhn32Jji5X2piKA8AOQLzIqkAL3IytI8GPp
         bIgCCUu2jUzme8rM1kjcdlT55eIy05wgolySNffau/tPqBhFvYIUupgOtwzbmLRowCBG
         vbTAVAgHLhDP5h9VyLYpnysx/3xpekh2ij5iHfH78mS/RhV1oVWc8pQK9ZO9Mpip5tKg
         +qHPapHO6Av5Da/gxOs0RBJN9E2WcceQTmQJGW37CpvcY8SHoEgJPQLbOsj9jFYl/8wh
         5aOsDQ/xEGluRfinUs9cPkQJ+EWin6B+tZMHqDBInbP5nN8Cqu6ZJQfGJmGgU0h9kRFG
         AHCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dVUMq2GT;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a191sor2346192ita.15.2019.04.09.07.05.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 07:05:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dVUMq2GT;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=b+cICRm86CSGIqdtgn80b09rxrmXqaSqq0j2KAMz0JU=;
        b=dVUMq2GTvuEL+u8W0s7GYxIeq3xKQLE2hX++TuHV7VC0WJZixVen01yG2ZwedWL74E
         +aQ3BHT8U6O6+LJSxTHvHAe0tq0F/TyWgZCzCpsU3hM1ILhU8qRtIyYOn3tAn3aTqxYf
         RmoNPSaa4vA1kfynpvXUDEgm8AXQijLdR8RUAgYyfisDnzo0n8cUwEwjwoqekwOgSoN/
         7y8+CXJnIIpokhM2mJmYgY476at7gjeeqUJLw1O8j0wDOjXOatT2pC5zdCpP1mOwax/e
         TBVNh1HkCz/31qM1wYRQMLOJEsFhznNxyB6nGtfpMrN4LePb0QMuEVGg+XNo9BgGtAde
         UqIg==
X-Google-Smtp-Source: APXvYqw8URWDQheLoWjUxybyKymWSXrYDgcpaQ+QNXIJG6uMZc7QuO9JFvDJKtRB3n3pcPKL/BcSiDgMgglKz0iN3cY=
X-Received: by 2002:a24:5751:: with SMTP id u78mr22192392ita.135.1554818704807;
 Tue, 09 Apr 2019 07:05:04 -0700 (PDT)
MIME-Version: 1.0
References: <1554815623-9353-1-git-send-email-laoar.shao@gmail.com> <20190409132551.GA1570@chrisdown.name>
In-Reply-To: <20190409132551.GA1570@chrisdown.name>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 9 Apr 2019 22:04:39 +0800
Message-ID: <CALOAHbA9+D-GGq4Z76s_wOKmmDKnTZzefvHLTn8JxmXThAmiDw@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: split pgscan into direct and kswapd for memcg
To: Chris Down <chris@chrisdown.name>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000408, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 9, 2019 at 9:25 PM Chris Down <chris@chrisdown.name> wrote:
>
> Hey Yafang,
>
> Yafang Shao writes:
> >-      seq_printf(m, "pgscan %lu\n", acc.vmevents[PGSCAN_KSWAPD] +
> >-                 acc.vmevents[PGSCAN_DIRECT]);
> >+      seq_printf(m, "pgscan_direct %lu\n", acc.vmevents[PGSCAN_DIRECT]);
> >+      seq_printf(m, "pgscan_kswapd %lu\n", acc.vmevents[PGSCAN_KSWAPD]);
>
> I don't think we can remove the overall pgscan counter now, we already have
> people relying on it in prod. At least from my perspective, this patch would be
> fine, as long as pgscan was kept.
>

HI Chirs,

Thanks for your feedback.
I will keep 'pgscan' and only introduce 'pgscan_kswapd'.

Thanks
Yafang

