Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 594E6C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:29:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 210272146E
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:29:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="QZVkVU5E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 210272146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0F758E0005; Thu, 27 Jun 2019 12:29:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE7408E0002; Thu, 27 Jun 2019 12:29:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD5E08E0005; Thu, 27 Jun 2019 12:29:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 788B28E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 12:29:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j7so1888809pfn.10
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:29:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=j3r/LDh8YvAZ3OZnTOWNg6U8i2IFKGtlQBfJAup/Xu4=;
        b=uPtWXob6TzKUUaWkUGlxGhuPpw1X4E/B09hR0wAKxOJ+gOrBgxzhJLphSul8agLxC2
         x1Zwwmwf3nrm0uXVl3qqJUBge2xEd0bi2NA/X/e++Go7M4vx4/nfuGzVHpFuUCL1CQKx
         8jt5CSPPCESY0R5z4KtYirjPUlyvApajSaCYu6gyTpzupavufv2IwJU31mNq+sOUi6dB
         h67UmtNXjMztg+ITc8veg5RBWfE0JNevB68gFwdnt0NubaIDXCHyA/Z/G5E7hq2Td7sa
         66wXFIVsEJiozQcxL1mttnlCZnpVh9wQ62Z8mha+AFvCHpSWqtOdEQVSOxy3mfDX2pw3
         jqrg==
X-Gm-Message-State: APjAAAUur8uu8jCk2VGc67ZxnKQap+vmDuOCKEg5mgM3o/dUQBOyUcus
	+kJHCBN33qEgwJUjc5iK+6B99S+cbfT7jzu3nDHZzjeDwAvhhDThqlMuuwd3+LgaovlmAAkYHtx
	GyXqv5mgNvtZ++lUbWwBx1QBdDtmq0Qas8N0y8yxZLNtHtug0Az0QcFCoB+ZazfnfoQ==
X-Received: by 2002:a17:902:6a88:: with SMTP id n8mr5708904plk.70.1561652954190;
        Thu, 27 Jun 2019 09:29:14 -0700 (PDT)
X-Received: by 2002:a17:902:6a88:: with SMTP id n8mr5708862plk.70.1561652953632;
        Thu, 27 Jun 2019 09:29:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561652953; cv=none;
        d=google.com; s=arc-20160816;
        b=l5AQN7dBO2zDaHO5MdlboVcJxgAJz+ZNIk44rIjqbvK0CPcpesKYBFhQFqf9yzGlw0
         U8Rv880CrliWTMd420MhimMu0LkkiKskJHO52UrA8m4fTlHIinYQ/sKEXaC0xhn+DSTA
         66BjeDs3t57+Uzt3h5A98DewL+CiOWKXLRbe+hX9XGOCxD+HtTzR6yG/8u8vqwG3keGB
         kq16JmGEkJRTbSeWsF02t7ZEj2pcOftwH2LwzOFMIKK1yj7ny4/CU1oYWgfG9CwlGUEd
         CfFLB8z9riIP2O20Bo+y08sgd2hK1bQNN21wf4lhfk69UEVH+xBKmNOyMtD1Xq5TXymt
         ncGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=j3r/LDh8YvAZ3OZnTOWNg6U8i2IFKGtlQBfJAup/Xu4=;
        b=UvqMgNsP4RyJa16Zk4eHVE+GrezCsRWJIpzDkJ7I+CVIskmPpUu3WDeMTL8j88bXEO
         skxUXxMABhCJhuCFYj7bdEhYL6o4D/KxqwmMoedE9+4S3JB2k8B1MDyHZix5kwxjMQvy
         WAkyvv1bHX9ssDMRKibxqFtmhIvBf6i/GxloLKpzBEne6STsdEDzU/IToYGzxN65YT+H
         7/qY66QoxSqUY+buPhXQfT4bG7QIbkSCpk4Y0dAvRH5GVd0YAQkRZrgBz7XB53G2xGRW
         ClS4vRFP8yM9pqJL+9M3x17YJzZkV4BXH3DzNCXLRffB5R/GHv/51AIGIqOMOrtR/8Pg
         1Cnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=QZVkVU5E;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k34sor1052642pgi.67.2019.06.27.09.29.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 09:29:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=QZVkVU5E;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=j3r/LDh8YvAZ3OZnTOWNg6U8i2IFKGtlQBfJAup/Xu4=;
        b=QZVkVU5ECiQEZD8bocjFgSEpqVctlMN9h8L1wAaFRjHXqF0bnW+Ftzzw3DzKHNAcjy
         nt1g/aE2ZEZhbd+4VS6rlk8nZwJ8oWZyePXLyV+B5tlPwkyvKPf9ZyvcqXhXbwmjBpsu
         9we+HaXyTyjBsGacmNDTBFRk/MACpSqLCaF7w=
X-Google-Smtp-Source: APXvYqwrMEoacKO75gwBZzta/Mh/OJxKqL+3tX7W1+GI48YaQAhoOPnpVsAFn4qoZf/KqcBmiY+0Bg==
X-Received: by 2002:a63:6a49:: with SMTP id f70mr4495703pgc.55.1561652953275;
        Thu, 27 Jun 2019 09:29:13 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id 12sm3220779pfi.60.2019.06.27.09.29.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jun 2019 09:29:12 -0700 (PDT)
Date: Thu, 27 Jun 2019 09:29:11 -0700
From: Kees Cook <keescook@chromium.org>
To: Qian Cai <cai@lca.pw>
Cc: Alexander Potapenko <glider@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Michal Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v9 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201906270926.02AAEE93@keescook>
References: <20190627130316.254309-1-glider@google.com>
 <20190627130316.254309-2-glider@google.com>
 <1561641911.5154.85.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561641911.5154.85.camel@lca.pw>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 09:25:11AM -0400, Qian Cai wrote:
> On Thu, 2019-06-27 at 15:03 +0200, Alexander Potapenko wrote:
> > +static int __init early_init_on_alloc(char *buf)
> > +{
> > +	int ret;
> > +	bool bool_result;
> > +
> > +	if (!buf)
> > +		return -EINVAL;
> > +	ret = kstrtobool(buf, &bool_result);
> > +	if (bool_result && IS_ENABLED(CONFIG_PAGE_POISONING))
> > +		pr_warn("mem auto-init: CONFIG_PAGE_POISONING is on, will
> > take precedence over init_on_alloc\n");
> 
> I don't like the warning here. It makes people think it is bug that need to be
> fixed, but actually it is just information. People could enable both in a debug
> kernel.

How would you suggest it be adjusted? Should it be silent, or be
switched to pr_info()?

Also, doesn't this need to check "want_page_poisoning", not just
CONFIG_PAGE_POISONING? Perhaps just leave the warning out entirely?

-- 
Kees Cook

