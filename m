Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A17D5C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:38:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AA09217F4
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:38:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JT4C1GZ5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AA09217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 056836B0285; Tue, 28 May 2019 13:38:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF9CD6B0286; Tue, 28 May 2019 13:38:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8D96B0287; Tue, 28 May 2019 13:38:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0F46B0285
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:38:20 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id a21so3541980lff.9
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:38:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=r8PmQcft5RJ51eoZR31WNho/xyilsVu7uCLR1yi4QeM=;
        b=SFpdBSzKGBtHw/AdnBTrdD5RGCOAUEyLfSpmUXcGMFKm90hzYQiMvjQCOltN93QPXf
         wCSTFTCCv2eCpkM/s+BGTi1qn2mprE6Yim+WsDTNSuc99kiqVG16XF7QqUoYhUB99+lH
         H+bMouJdlgarzg3oKFR7Jczsg8Nu7IqhbiwMs3PBs4JLA1hxr339nkObspr6jXiGLfOr
         mD4vi4jNLoIXJ5Fi9yr3fQszEIjrWgmHT1lKF+P7E8EO5DDfXlZvH1C/x5gQWrXRkNVB
         ANkcLhjTm2jhQO7pk7KVmRTZA6R6vaYmJXPtg5/vBMqz7GDwGi5X5ZHx2V8CaM7//80q
         tsrg==
X-Gm-Message-State: APjAAAUka0mvY2J5nyyewqKXBxZlLTIuYoNcmRieSeNWb/tI5LGjPs3/
	b0lnORqg4hc8wVR1hAL5nMsKitzIN2j0En93y31Pm+qv9FjkvLr7lg+2KwNfDjUvnXjuz4fRsk8
	49F+C1gFAZXKclZFxitZ5xwiCvfr13c4Flcx8Mvxmww+FE+MIVjAcahDsALFz+zfxQw==
X-Received: by 2002:ac2:5a41:: with SMTP id r1mr63328478lfn.148.1559065099977;
        Tue, 28 May 2019 10:38:19 -0700 (PDT)
X-Received: by 2002:ac2:5a41:: with SMTP id r1mr63328452lfn.148.1559065099256;
        Tue, 28 May 2019 10:38:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559065099; cv=none;
        d=google.com; s=arc-20160816;
        b=hm4je2LxDENSBCA66y6BJiSj7cM2c9ZcQzo9TNqLfPBt+O9HKOUnFEjeYjiTWcawZh
         CH31scGx43GNg927uhv213vA71ZOmmw8Nxpv5jU2cnrXwF2vmOdOqtlCxrId+By2o/gX
         0A2IlLL1J74zKEFGBJmouRdPbYEt56yJIVx1d/RK35MmwdURrTQMzlkLV/J5LC92ORKF
         NLvQSEg/pnT4QzyP6bapq1fV1yQ6Z+xZrX20+AdlWv1OnXDl8ZiHfY8cOhH1ovAueqLG
         RVFiC3fG6yYGJGpEbZRiKnbEOtX5O5IoNCqyJyzyWRVoPRDCQzsWrw0f0KTcNr/sHJsL
         Ml0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=r8PmQcft5RJ51eoZR31WNho/xyilsVu7uCLR1yi4QeM=;
        b=t0hEL8PzCuOnWP8i+5hPTKiI0oBXkvF8irIUHhm/+MtYPR6Yv/4qHsjCgp15kYpCYP
         K7ZXTjQ11nYaa0p0NIlmY7DluW2UItAkccZoPxmg+B3EykSLeEgDS8WEQ02fcPaZ7KHx
         XNynFIdYM9bJL9cwDwGj8DBqXMcZxu6nSHXhO3sBcKbyxNusBTX0SoJDM282XyTPhFqT
         KiuEpG/4HyS3k342zws2+lPGjHf5TlIKQtKj/j+10SF/DjiIjRT8MRlrxUS8PxB9Bpz6
         cur4mG4Yixj3Mretyoi6DwmpFo6KzhgdEyAXlBFkWqdx97rJr2kaHJXMOm1JS7deMh75
         qv8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JT4C1GZ5;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i12sor1431525lfo.73.2019.05.28.10.38.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 10:38:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JT4C1GZ5;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=r8PmQcft5RJ51eoZR31WNho/xyilsVu7uCLR1yi4QeM=;
        b=JT4C1GZ5u716MuG38oMA8m4kjqZNa8qKH9ij5bmN31mD37QnGs2q/DkpLNNQT54Zah
         rUr1i5yoLx+yn8qZ9Z6/k+NXbn69dEk4UXskpJRCo4dqFVYZi1Gp9O+oNSmX7wtFtmTW
         i41ZJ+O6WEW+B/XteUFnOgI6Ny+omV83U8+9UxpLp7+YOX51rxGfMYlVkqNg9scqKNfI
         WJIUBk6E9hEM4Vz1E/YKBi102DMg1BYgG9OCd3G59CHXnh2xpEjE3S386PD07hkNTX/E
         2OeALMR2jlduzQUdutJqLwqHpL4y34Re7iAU4oyso+lxa2BJz+GZ5rAHJg7MSOyUyYXg
         XYOg==
X-Google-Smtp-Source: APXvYqwduzggJa3CuKgzzvG/ZBPz7SyrVxU3HSrA2hFtyUmdW0XFIf6xWdZSBNqyarXqgVcEOsgxzQ==
X-Received: by 2002:a19:2981:: with SMTP id p123mr11785310lfp.190.1559065098989;
        Tue, 28 May 2019 10:38:18 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id q124sm3003230ljq.75.2019.05.28.10.38.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 10:38:18 -0700 (PDT)
Date: Tue, 28 May 2019 20:38:16 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 7/7] mm: fix /proc/kpagecgroup interface for slab pages
Message-ID: <20190528173815.2km65nchedfumslt@esperanza>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-8-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521200735.2603003-8-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:07:35PM -0700, Roman Gushchin wrote:
> Switching to an indirect scheme of getting mem_cgroup pointer for
> !root slab pages broke /proc/kpagecgroup interface for them.
> 
> Let's fix it by learning page_cgroup_ino() how to get memcg
> pointer for slab pages.
> 
> Reported-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> ---
>  mm/memcontrol.c  |  5 ++++-
>  mm/slab.h        | 25 +++++++++++++++++++++++++
>  mm/slab_common.c |  1 +
>  3 files changed, 30 insertions(+), 1 deletion(-)

What about mem_cgroup_from_kmem, see mm/list_lru.c?
Shouldn't we fix it, too?

