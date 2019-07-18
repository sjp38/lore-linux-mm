Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 361A2C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:39:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC815217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:39:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="FDFQtZ4z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC815217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFCBA6B000A; Thu, 18 Jul 2019 07:39:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A866F8E0001; Thu, 18 Jul 2019 07:39:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94D916B000D; Thu, 18 Jul 2019 07:39:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDA46B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:39:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h198so22982128qke.1
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:39:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=3iT/OaO0Q2X3P8RhjupPqyY23NtLVrvRLicg+uM8g44=;
        b=Cmp+QBBcc/3RArx5nMtzu/FVWXhmezpGN4GPVKnZJ6P+F1UajibjkMwyppoNCfZQ4z
         6Az9n+LmL+cSdwCM7oVRPnVOm7Pv+EztK5x83OX5sVLqOgtm5cO8Bp3oYzboFswhDDnP
         KEiDmEm1q2k6CIovIYYTywm553SLaMWXvuXYVvB6jrERp5c/luw8JApTdsBZibv8LjXW
         58cuqRAPgr5uhGe3ixHV4mHX+Wewh3aGape3fhgmAU6hC7KRGjvTeo6W8+YVkA+agYTr
         w5B+JWS6u0FR/fCj2gqEDFRZNJZIFcf2QeyLKAFOX1YWxxI6sz42JQBto2Lqag0wbUNg
         3zhg==
X-Gm-Message-State: APjAAAXJ8I+7t7u/+VwjR2FpE0+cGVp1gJ6SoRrO+ExPMt6Swu6p/72J
	rDNaJXPDamuO80UZHzoCnEt/+TmQnH92VjdGSY6y2zwdQad8qGufcOGPdyK9jctzWujmnNngTE/
	h+vUewUMx3w+hY7fIdpec4Rhvry2U/iDVdVFqw42TdvgY/laZMDNGmK2ovjXNXiM=
X-Received: by 2002:a0c:d09c:: with SMTP id z28mr32235008qvg.149.1563449973250;
        Thu, 18 Jul 2019 04:39:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVFi/BQYZhso/VGO5LkiPQOSu9HRm6Cmqdfqus3qGV007avhTO1yFtVt0ZNi48iD3PnfXp
X-Received: by 2002:a0c:d09c:: with SMTP id z28mr32234974qvg.149.1563449972798;
        Thu, 18 Jul 2019 04:39:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563449972; cv=none;
        d=google.com; s=arc-20160816;
        b=K2O5QQHq6gVw4IwKRsGwR//t1ne8IPkOVrvj/pHjFv/ERWpiCPtQjaJ6A46ynrBOBH
         hsQ4gKcRAux6peoAYW3sIAylA6wqLWO+CG60ZWm25zADnMAop5oG7DlqPmHfQhyQEkLT
         1Vn0qcok7bRu+M1XfyFoNnyS6qJVu2P8BFpD2N6oeHb791DgaSMr6R9/S54Dcw8BdgkH
         kCXIxubuEV39dMgQwZ8mOhmerxaYIGAwzx7oTQvfSboZQPPWUrP0mRek+h+lXIMXo7B9
         L2wQhwjybFH7PK5L+rwZWYCJ68hs6vFeMxotjYDRDB8HzE244TnvNbkhO136IUn7sQGP
         M8QA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=3iT/OaO0Q2X3P8RhjupPqyY23NtLVrvRLicg+uM8g44=;
        b=hA98DkR6oLo3PBgeGi6oZkTVEBC6by/2bILH57P8MJ9X6xhJ4lsekhWca9EKLt96Ff
         TAc1y3j/mXcrrBsaxdb2G3sBBlRNWrvJIrXMpaAAE0tvShx3U6pGH8cX2pRq419jI/hv
         O/n0iOLe4SoFRWEkrDCMsgKUp1hqg3wFuoiblAfYh0c3su6Of/52nm4gx0yp8gfwKDUR
         Kfch2YCqZ+09eIW0lY1nCXJQ9+/rgo3TikOcWQzjPpw9BkGko+ewuh8RWgFTADAGTajo
         TpdcB1i8UVIBPJymcGpOiGaFVqIHDqJBjLuVlTv4E4ZqYRSnRppNUv7hVavBCfg16ssV
         oqpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=FDFQtZ4z;
       spf=pass (google.com: domain of 0100016c04e1562a-e516c595-1d46-40df-ab29-da1709277e9a-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=0100016c04e1562a-e516c595-1d46-40df-ab29-da1709277e9a-000000@amazonses.com
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id z7si16781410qkb.134.2019.07.18.04.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jul 2019 04:39:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016c04e1562a-e516c595-1d46-40df-ab29-da1709277e9a-000000@amazonses.com designates 54.240.9.114 as permitted sender) client-ip=54.240.9.114;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=FDFQtZ4z;
       spf=pass (google.com: domain of 0100016c04e1562a-e516c595-1d46-40df-ab29-da1709277e9a-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=0100016c04e1562a-e516c595-1d46-40df-ab29-da1709277e9a-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1563449972;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=3iT/OaO0Q2X3P8RhjupPqyY23NtLVrvRLicg+uM8g44=;
	b=FDFQtZ4zf6FgI43zUELi6/Zg+fvJYbr4Qi8Uy1KRexi8MISbZNS8UXYwlbwZtKjr
	ZIcLsvcRKg0taoqGZ17XIpRSbXCYzGRGkp10Y+jcpW8bkQDY7U0lVrCEYNhOxWMj9fc
	tr6WLHoRK9d2cxDtjdaAcHLtgqjGMyN9te7rG0NQ=
Date: Thu, 18 Jul 2019 11:39:32 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Waiman Long <longman@redhat.com>
cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, 
    Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
    Shakeel Butt <shakeelb@google.com>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 2/2] mm, slab: Show last shrink time in us when
 slab/shrink is read
In-Reply-To: <20190717202413.13237-3-longman@redhat.com>
Message-ID: <0100016c04e1562a-e516c595-1d46-40df-ab29-da1709277e9a-000000@email.amazonses.com>
References: <20190717202413.13237-1-longman@redhat.com> <20190717202413.13237-3-longman@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.07.18-54.240.9.114
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jul 2019, Waiman Long wrote:

> The show method of /sys/kernel/slab/<slab>/shrink sysfs file currently
> returns nothing. This is now modified to show the time of the last
> cache shrink operation in us.

What is this useful for? Any use cases?

> CONFIG_SLUB_DEBUG depends on CONFIG_SYSFS. So the new shrink_us field
> is always available to the shrink methods.

Aside from minimal systems without CONFIG_SYSFS... Does this build without
CONFIG_SYSFS?

