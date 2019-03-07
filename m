Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 142FFC10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:11:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C45D020851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 22:11:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="LCTOpdFA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C45D020851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 676DE8E0004; Thu,  7 Mar 2019 17:11:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 624208E0002; Thu,  7 Mar 2019 17:11:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53C4A8E0004; Thu,  7 Mar 2019 17:11:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 24E6A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 17:11:30 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id j64so24835514ywg.22
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 14:11:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FHC23kKOOD8L5WKDG46G396bmkMA7Azge/SSFHjSA8k=;
        b=CUkSeKg5uzg3jT1lzsHidZj+uNQNYvMZTA51VjiP1AjPFiaf9ANbUEPmNcT7Ld4dlB
         G9RTqPsRrzeWIcSwJH9Wf+mYJPdsnoCyTNGSGmovDdbA6EIvLO2TUWptuWIUu/WUi/sZ
         BypObnNpCyHIM3y/4Ix+bBtpvD2U8Hsknb2zMAq0UEba/KlheoVF8vbyVlMvLtm1tQC4
         s8PCXfuS4RHHTb4xHF5KQ5SaYeyzjboBNKHIDRRyVsYcOscXJZ+aVckiys0tmcoY7+w7
         66WlFDMlPylh1h45q0jT3qyn+rMYQnSz5fkzi4irT5zp3OlvwZCLXyHP/L+38XN/bd5R
         xbFg==
X-Gm-Message-State: APjAAAXLAt7e3hrI+2AM3LQ7QXX6/p5yVDsx7+qCe0c6VLpf4JZmydPV
	Hpc+lvVNLz968cTbmKPHBsbCAA/86KyCTz7aXr+YXPNaP/WkAZ+rtZAzaQWK6dwk7A4Mw/zjEDy
	70VnzDBaVuvl4LCRvQPXYK8GMhQYghToc41LrGfPjjUkYztaWOolTKPzWXEBUYwUhq3BIHLKG+v
	EJhr8oUF2fQU4etTTK+63YQLTlo4bMHyjuii1N+O/fNvqPCZ537u3hpEGLgk/QxobFzuZ9xREZS
	4bpe+dVyA4I0m9lYCqyuk60zTcFN2HaySij2wK372H5PxsjcjzODfyGaxN8k/PWLFlwN8foBn83
	3IjfJhwJ7OSTe8kElFETo02aTQAhYSFQTzUaUKAwa3O3ix01GQ90yx0SJB3NM2L5xJ7cUIHdJfT
	2
X-Received: by 2002:a5b:552:: with SMTP id r18mr13077362ybp.381.1551996689871;
        Thu, 07 Mar 2019 14:11:29 -0800 (PST)
X-Received: by 2002:a5b:552:: with SMTP id r18mr13077309ybp.381.1551996689081;
        Thu, 07 Mar 2019 14:11:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551996689; cv=none;
        d=google.com; s=arc-20160816;
        b=yyok2zb6bQ7qpO2tqTLW6Xrvc44QSEE09RWrjOMTEyuCgVYo/vl/1f5b3JWiVkfj6C
         sKI83uS67rq+Wkbq596SHNgwgXqgVHmmpmvSftOeorQ16QuGC9G4qG3hQIA09XRwbbqH
         mUiATz2wTco+qyLu+H67+h9aqE/UH+iTJKpaTDcnsIVruvUfwQ8czD221ujsRM535RxN
         6YTvB8DskA1Mz7ig1zmHeyu0nBDryssrC5gUQ7MY9tmyoZcQoW/ReRFOhZAk2ze8XB6E
         DoQ5x2Lksu/1r+NPBQsaPCQ890WTmiRIQAaOxGdqWqg8nfCteti+IwWY08rsocCrGRu4
         WFFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FHC23kKOOD8L5WKDG46G396bmkMA7Azge/SSFHjSA8k=;
        b=VPJoJv09zHSpNOvvE6xkfL8hgEsD+16YReYHkOHhgopuuWa5d/udNZyZZfW/XDkSMV
         7scxU+7uycX6ZsEBnW80xxqvAmUegNI5juuUhiHSioV3BM2Np7ulQQlwKZaedqIEH6VO
         0TSLOSB90031hP0jC8/1A3Lz1LfTAAKTCMnaRYEM2UJCBZcGFImCKjju5hHrJNZxhzf6
         y7tsqIB6Pyr5YOYO1uIFTYZu8+V2M9SMpSPsrJm/nYYNIdH2Nw0xj1u2rVtnch3gJ0xu
         npnCW/6BOHY6ZW2VOyvsKlR2BeNjJ34STV6jkz/5Tz46iAZrPmuR+Ji3zjuX3aNXtC3z
         XWyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=LCTOpdFA;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i9sor858873ywc.133.2019.03.07.14.11.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 14:11:29 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=LCTOpdFA;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FHC23kKOOD8L5WKDG46G396bmkMA7Azge/SSFHjSA8k=;
        b=LCTOpdFAw92Re/ux6wXEumAMdp9TKQwpTrSs5Lh/Qfasc2H2gJ2JHORCOPqt1avoZp
         1tmaIxawMjWKMK8d+zD5JXjklFfimS9r/BqlbkyxHnTZO3x7cQwNnqJ6es6GzRicctNr
         EaB7LXmyAAXYzveD3svhTn+/IauwuK4QoRDoCm2/Sa1cRGHc3hk/h2+0fA/HPC4JljMg
         eiBJ55Ma79JLsP+jPuXuNBQYRQXn0ouq7/HS6Awte0dQHoJnfCAUHQbnT3JVi8TC+/t2
         IAmlCYL0po73tQ2RrijK8nFHuYWuO0Irn89uBprLX2gDt0zoB7NLVDWnzkdl4ndXwcmc
         424Q==
X-Google-Smtp-Source: APXvYqzJQV9pKn1T+xq8tEvgofda0YcYf0p7M5EupWuyPIKGF8VVn1dVryBLfJtwZGN7wSmKfJ91bQ==
X-Received: by 2002:a81:5f86:: with SMTP id t128mr12396998ywb.467.1551996688797;
        Thu, 07 Mar 2019 14:11:28 -0800 (PST)
Received: from localhost ([2620:10d:c091:180::be7f])
        by smtp.gmail.com with ESMTPSA id a194sm2078380ywh.103.2019.03.07.14.11.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 14:11:28 -0800 (PST)
Date: Thu, 7 Mar 2019 17:11:27 -0500
From: Josef Bacik <josef@toxicpanda.com>
To: Andrea Righi <andrea.righi@canonical.com>
Cc: Josef Bacik <josef@toxicpanda.com>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 2/3] blkcg: introduce io.sync_isolation
Message-ID: <20190307221125.hy2j76m6tv7vnjpr@macbook-pro-91.dhcp.thefacebook.com>
References: <20190307180834.22008-1-andrea.righi@canonical.com>
 <20190307180834.22008-3-andrea.righi@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307180834.22008-3-andrea.righi@canonical.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 07:08:33PM +0100, Andrea Righi wrote:
> Add a flag to the blkcg cgroups to make sync()'ers in a cgroup only be
> allowed to write out pages that have been dirtied by the cgroup itself.
> 
> This flag is disabled by default (meaning that we are not changing the
> previous behavior by default).
> 
> When this flag is enabled any cgroup can write out only dirty pages that
> belong to the cgroup itself (except for the root cgroup that would still
> be able to write out all pages globally).
> 
> Signed-off-by: Andrea Righi <andrea.righi@canonical.com>

Reviewed-by: Josef Bacik <josef@toxicpanda.com>

Thanks,

Josef

