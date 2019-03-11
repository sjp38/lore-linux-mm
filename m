Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18EBFC10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:14:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A84E92087C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:14:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="cbnTo9uh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A84E92087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05CA78E0003; Mon, 11 Mar 2019 13:14:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 009808E0002; Mon, 11 Mar 2019 13:14:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3A998E0003; Mon, 11 Mar 2019 13:14:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id BEFB88E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:14:06 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id y9so4979607ywc.22
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:14:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=y58oEk6VFS6vSzvCUZ1rAopBEFvhw4rM0vVvFY79z3w=;
        b=keX1QG6bLYDyAbG1NB00HsM/bIaJ1KvmKDbVojeQrB3E8M85M7z/vsXf0m/CROLaYT
         Fjaq4dnoP99L7bCl2TIp4M997DvzwiRQ6NROKFrOWxtT9SLAw3DavmTtR5oYB0v4Ct6V
         TzxXSaQcM9kEKgNIIzBAKszZPb/87Pjr2Uvqa97nzGB3znoWgLUDEUsSARUJl8WbkNyz
         ycqIaqqHXQDJP/ptn3ncixmbNVJl7KYd5EKgJe1GUGzIFl3yd47R4hpyqKP2Ue9JPJpW
         UXH3qwO6mJ9aeRjapcLxTVzDJ+73FFig02IeAUg9kFNb9t3oASFWes2kjnpk2EyRhG2o
         MPYw==
X-Gm-Message-State: APjAAAWBrocs6hfy/v9EJ+Cvq3CXmyQm/Uw6cn+hifCS8sYwMDXDXDt8
	kJ1fJgWhCJyzSz6Y/bnJAHWg7zXNBPN+AvMxou2g30GBJhNsm8jlgxFuGhXPDM9gb8lpOmh89Ho
	nuCsxiGvM9huEQxVYGEOd6CLs70SufirfClWXcC5IBPIL1UXPpW3GMWL7PkK1iBJm3R+ZWq1xTF
	hTcuPyxkOxLsDd+8gRVRmIsw51sD5CWNEWNsm/rPkrDWK4B9L/luZ2Ib0pwD17b6aYvqcD/Dk+t
	Oy8oXCu99lxpVpyRZyUtgzvIg/kpllgqZb3CGfP5QDcGxSzT7PF2StfA6VISI7dhE8K6iNpJxUO
	UfjoUbWUDT5ik4bUWpIBA+uDrrMrhYbLPH6B1j1mSa9rW0oxuSL/UIHQYcCMjk3G9GnwkFVqB2F
	Q
X-Received: by 2002:a25:bdcb:: with SMTP id g11mr8640584ybk.227.1552324446423;
        Mon, 11 Mar 2019 10:14:06 -0700 (PDT)
X-Received: by 2002:a25:bdcb:: with SMTP id g11mr8640508ybk.227.1552324445409;
        Mon, 11 Mar 2019 10:14:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552324445; cv=none;
        d=google.com; s=arc-20160816;
        b=V+k6HCFFqQE/h6Ocq6k18o5J8nnet11REIi6q0SRgYBQTC1/MFFaakZb/uD+yZXoNe
         Jo2hyGZspFLnak+4gvZbIfKNLg1jvDss4mj5TR0KZR+RA64XlbFT7ki7BAKBa61FDFPW
         tyF9hPf/++z7HgjdOihgy5bmw0ut0P7srTm00J+/WIq2NNzcH7jdgGIjT8U+jxEOJKQo
         5kYhYwph2Re7iWo6zwnU2R/wAArvxRqnsy+KkF8dn2rwRA7KBilLCaDWHFlSY33vIA5L
         Yez+BpISRgfdGMCwTCOd18/tK+kmYm6/mDrQSMMRcUzye9pw7Ou4+00N7xCxPpc+s5nY
         Epuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=y58oEk6VFS6vSzvCUZ1rAopBEFvhw4rM0vVvFY79z3w=;
        b=Z7j8EKVduS8cHAGYw++XS+wTO5N8fMAQtRoNcerhPQutoJQbDPWQL4kVIxetqe0hLg
         Wypdg7mwTPbCUe8+mcPu+AEqXNPUQg3k4Q0TncxIN7xT25paCJRH0pBDVKyx8aIIXyJB
         EtadMGFNbj7UPh/JzV8wiKbVor9PRrTPP1IMmu/TGcyh6Ir4/wcrw23Mqlh/O8jeXP3J
         NInKgeBcpyIkxvDIyTVuCtdHWeCi4R1cMF71iJGDCqOKiMld+sKCX0lETpSUH2ZzcNIJ
         tiZgshUof0DC3mkARo0qZ4txvWuKkdjbjQyqP0yoAtLH1ZUNYillf5f9YzJpGWuXyDi4
         WvPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=cbnTo9uh;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d81sor1056637ywh.135.2019.03.11.10.14.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 10:14:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=cbnTo9uh;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=y58oEk6VFS6vSzvCUZ1rAopBEFvhw4rM0vVvFY79z3w=;
        b=cbnTo9uhVT9wL0/pDjHdpqDCQAmDqAAWTT5Y5z3BS8FgIRZRCmrMBSupLQtrmwiEU7
         KNWY5PgO92GOlMjDPP0UOCN5cJxUoHP6F0cYtfYBH0kvGx0Df9p0KqeMeAinp7e6Hn7H
         qFeICoJOIUdbPnLvus51stmzJXaJ/+uInYfSGDOxkAxWBeJKtUvW2rdohxe2yz7qvTQ6
         0O1D0M5XS3k4/pk8AY5EFdwCn5gOgS7J1ZsHZ45xqR571yERkeULGtH3An/Fy/czxlTE
         94o1WvQc7t0r8iKPOxsSvgeCImOhz2aSP1OZVo2zCD6Jtc2HJuGJIQcB4TXESbv9wLGo
         hUUw==
X-Google-Smtp-Source: APXvYqwbksG6pV6NHQrSLAiG/AmNqN4B0KIeTZpNK2uAn6ch6pNfdQ5TPs6pHjzKEEq0BGkEHZCHyA==
X-Received: by 2002:a81:a055:: with SMTP id x82mr26386742ywg.177.1552324444748;
        Mon, 11 Mar 2019 10:14:04 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::1:3c60])
        by smtp.gmail.com with ESMTPSA id j10sm1933530ywb.39.2019.03.11.10.14.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 10:14:03 -0700 (PDT)
Date: Mon, 11 Mar 2019 13:14:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>,
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/5] mm: prepare to premature release of
 memcg->vmstats_percpu
Message-ID: <20190311171402.GA10823@cmpxchg.org>
References: <20190307230033.31975-1-guro@fb.com>
 <20190307230033.31975-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307230033.31975-2-guro@fb.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 03:00:29PM -0800, Roman Gushchin wrote:
> Prepare to handle premature release of memcg->vmstats_percpu data.
> Currently it's a generic pointer which is expected to be non-NULL
> during the whole life time of a memcg. Switch over to the
> rcu-protected pointer, and carefully check it for being non-NULL.
> 
> This change is a required step towards dynamic premature release
> of percpu memcg data.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

