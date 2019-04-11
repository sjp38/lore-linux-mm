Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3ED9C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0583217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:42:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NY1nUxdd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0583217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B7EB6B0006; Thu, 11 Apr 2019 08:42:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33E766B0008; Thu, 11 Apr 2019 08:42:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 208A06B000A; Thu, 11 Apr 2019 08:42:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id F1D716B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:42:09 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s184so4668591iod.23
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 05:42:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oM6PnzvnVDmlRb+Mee30gqe5tWlJJWpjoRa69BQUMvc=;
        b=HTWtE2RlgLSd0drMRnKOngikSwfkireCsh4TzYsqwS1aUEOmKjRWIagFJSInTOUWdu
         cVLhPVLOmsi81xn4QCF8qESiTnYPoJARkma5DCD0AuvBJ4nTR/+5eECUCJ7o9/+qaqii
         UHo+Shq3Om9qjhS0uZe6VO/k8DMP5R14RMDMeWL1GX14fUPWRYadbnmwYrlXrOl8l6qc
         rcDMCCqIOZgF/AfgNO4iurGMGLZJmDKMssYiSlav0ctKEKMTrceTVPyihQtsvSTmO7E3
         ZOIRRYMdiaOt9qtkQbK7KIwaqTmChReUbFmHLTeJuHCwuvrz7LUDuj9wK5FfwMh0raIK
         y9KQ==
X-Gm-Message-State: APjAAAUXsnPDNDEOV7MkPHKuyJUmVGqCmqBB2JVqL3Qcw4364+5DDKSS
	XlqG9/iYbM3a8wtAJZFaNkiBNGXIMA64mkJZSkMXUJ2T5nfU8SewaFJZG4WLZW8EyOYk40ByQIT
	E7+K3bUzZ9+nhBmX6w3xnKERVkKJl8jP9su6gthnHJ2GOg6FQpoRwGrA4eesr01RH7g==
X-Received: by 2002:a24:1314:: with SMTP id 20mr7779047itz.137.1554986529678;
        Thu, 11 Apr 2019 05:42:09 -0700 (PDT)
X-Received: by 2002:a24:1314:: with SMTP id 20mr7779018itz.137.1554986528962;
        Thu, 11 Apr 2019 05:42:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554986528; cv=none;
        d=google.com; s=arc-20160816;
        b=scjr7pm1u60ctO6FuWJb8p3eqGAoXWSFWyBOWBOxQI2v/WJj4jolVzFyxLIkGRfRme
         yBvZOUjfroz8idxC70N2deSWiTY7cHIzn1M/Bw2RtU1TEqzqmecoRzuXqWoMtZxd26/q
         R9JvJfEwE3bCenBl8zKCZJ97B+MeKPCIVc1jVMNUsMtVEs3dicsCGT2kh6pyX86WTFww
         un2f78fz5NDJJgZAYPd4s7uAHUr7W2u41qz73+eLiRHOWgHxKxPUW8+Kq0jKTsZ7BM45
         hMCWmtYSkmIMAkensEAUUXL66RzSB7gHHWz+Xr2Sx/BIBQXd+n7PscQ7vUp65Mk5N57c
         EUSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oM6PnzvnVDmlRb+Mee30gqe5tWlJJWpjoRa69BQUMvc=;
        b=AFHcle/H4EQNA4hz+BhGq8uT0OtyQyyAk4Q9Eee8Xy4Dx8nRuuPu044SKg9XPzpEp2
         ybAEdZDxNQ7ePa7LpUFDt7GdwUvyZ1Zt0AFJaOdQbiQ1aAcRQAiSH8cHku6WbwGxPpYZ
         9UHeLruz1qvCC1wbi73clccKS7GvFwgtx+ST3EYBrhZhs9rHa7VhlX/HxVSTALgphECV
         mCpRyIEEecFzb0+PBX/vaN3igK9EV9Or2fQJpPKXgrUYQ75jGUcAwai6Hb2lARMtw+zN
         OReyoskeXr4Kb6c2iDCBELSBeS4X1vIlv/qwtoueSC5Fd2lluAG02hRygTiWdYpDOnqV
         EhhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NY1nUxdd;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d198sor8537562itd.10.2019.04.11.05.42.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 05:42:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NY1nUxdd;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oM6PnzvnVDmlRb+Mee30gqe5tWlJJWpjoRa69BQUMvc=;
        b=NY1nUxddfxrvZNMUWJb975J6YvpNzdI0yaqfBYuk9auNyfXje4YgaY7hzgbWqsUQbX
         GRHE5S1bbNTbNGV77wQgwegItoe0VWLYFswzu3bQolF4vQczqbSxbbiIX2jKiAwQ3SIE
         MhVEMb755kl6hDkCr9XVljMBn5+KxjVmKmYDA/QggJjyZOLtOXisN6DHJj0WzVB+ncfB
         IRUzIrXZ+WJ/N+nO0oMXObRbKLAeLKLOgRfcCiwkqdTxLKXxxG5wbA6Pz8Pq5qFie6fE
         rGi9D23RbZuVQfAHDAorPhJAGWVZCd6Va9Arf8SVRenDJVE6rAsnkpNz3I8jE2Alj/IJ
         8Onw==
X-Google-Smtp-Source: APXvYqwiKDU9GU8UEIndQolJA8B3WMtMZnEUOd64S4UZbAwlvb1g6Q565cgL9k6UO+unHdiF7H0R59awwu80eOqTmkY=
X-Received: by 2002:a24:ba15:: with SMTP id p21mr6877505itf.66.1554986528733;
 Thu, 11 Apr 2019 05:42:08 -0700 (PDT)
MIME-Version: 1.0
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com> <20190411122659.GW10383@dhcp22.suse.cz>
In-Reply-To: <20190411122659.GW10383@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 11 Apr 2019 20:41:32 +0800
Message-ID: <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, 
	Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 8:27 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> > The current item 'pgscan' is for pages in the memcg,
> > which indicates how many pages owned by this memcg are scanned.
> > While these pages may not scanned by the taskes in this memcg, even for
> > PGSCAN_DIRECT.
> >
> > Sometimes we need an item to indicate whehter the tasks in this memcg
> > under memory pressure or not.
> > So this new item allocstall is added into memory.stat.
>
> We do have memcg events for that purpose and those can even tell whether
> the pressure is a result of high or hard limit. Why is this not
> sufficient?
>

The MEMCG_HIGH and MEMCG_LOW may not be tiggered by the tasks in this
memcg neither.
They all reflect the memory status of a memcg, rather than tasks
activity in this memcg.

> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> --
> Michal Hocko
> SUSE Labs

