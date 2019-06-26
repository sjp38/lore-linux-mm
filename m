Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1CE7C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 23:28:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 485F3217D8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 23:28:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zmegpjl0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 485F3217D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD9466B0003; Wed, 26 Jun 2019 19:28:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B88D68E0003; Wed, 26 Jun 2019 19:28:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A780D8E0002; Wed, 26 Jun 2019 19:28:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5D86B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 19:28:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h27so231313pfq.17
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 16:28:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gXeunDalFpMfH98V7l4lLnV8cjyh/Jd2FfSneJttMwI=;
        b=KJJ3eMvQvPlWDV9wouRpA+/cCO9leAVneaUm8ye/dzPmWliWQhar6C/VUbZG+Vg0P/
         btNkYLt0DXa/zE5o+9epUN4F3Nq7iFioFYP1DkQNxdSUyN0GgVK5YlrEHWtasgqxoNjU
         aT3nsnhGlkHsw3IihIE4we8I1tE/YUyjUwJxWFO05RUDb49bg78MCJ3zIr/0/vl2fu85
         ju8BUTSR5FdO5blINCW+cfj9CgL3kFDxvYTqUm0aN/BSo782tqSHFvN4S7Htkq/WR7zE
         1tNVpkqkJu4NAyXzBcZsdxkoLFEuml5d3Gn52ZNNVFKPwTStRCYCSn6UEBqQl9ktENBP
         Mgkw==
X-Gm-Message-State: APjAAAUabOjKGD9Xb4CpXOdXIFUsAdbItGGZ0cypukEYBL76fVtzUw5t
	63aQp1VHBsRe4F7g7bDjBThQ/wty2hog8fOGD+sgmNg7J8N1aQIS1zLPypT1Q37QEtbkYoXTsvc
	fsAh8hnM0020ymI7AiV7A2DYeJSs3Xw5G+BmbYXCEAejAbaI8E5i1zM4n2F2p/8fmoQ==
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr839212plp.166.1561591717958;
        Wed, 26 Jun 2019 16:28:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/4GccYkPZ8xqH3HcjWTDIoeiNUL3WJD3CR1Pht1P/cC7Q1RvUrFYzyr43WvoQ7iTiar08
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr839150plp.166.1561591717192;
        Wed, 26 Jun 2019 16:28:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561591717; cv=none;
        d=google.com; s=arc-20160816;
        b=Jp+bv2HlzW6+2kqBsmmIAGfH60L0MYb3AKeeMvOKOQdIH+VyRVP+tpOh5uKyZVtXMo
         kCguV8rOz6GZ40m3rjhG0CHz60N6GaGnLShtAShOnSsB/hErTlOtNkjjjuHy86g5AuQb
         BU/gm8v4z1u4/3TnKtRGv0QyAa4PojaOPZk+h/GL2oz5LEWe6T9BqpLsz0VT1+CRm66I
         Vr/gdcPU0Y7Go6vEljMK0V7Y6YkUtOEoHvTRSru7QmMPPSh1l98AnV1fZ1oqq2Ta6FF+
         9u0lw1bnpw+1V/dZM6236dQsgGTLH9LJ5GXAkC8+XRz7BfvOd2aggS9Y3K368IsR5BV1
         zTbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gXeunDalFpMfH98V7l4lLnV8cjyh/Jd2FfSneJttMwI=;
        b=bDP4eUij9lDuM1BxLS/QC2OK+ukiVnJeiIP7IjqohnZg9mi80CsK4DALZWpEwX3+Vf
         RTO21MLvzl9jIcVcQQQgmwjpl1gwen8engxV+o2ToJiC4cRPbNJkQmgG2DdqCKvnqOYl
         RGBMZq5Fk12+oVSsHWFnFpREWoI1fatHDh+T3eJue34X2q1dwePkuiuWY+of89caTSm9
         9yxEb5/IrcA9LMIgtod3po/HA0WoaVCBXC1Hjl/jyHhUJ8rrle0nDIDPS49W+rlaybEd
         rSb2JsXQeA7N0kNQrTt88rmAGHzq9r3eASwzRDsNXvl/U9toqV7Mw/KUHT17oH5Dkfyo
         4iNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zmegpjl0;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e21si363335pgh.571.2019.06.26.16.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 16:28:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zmegpjl0;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 11ECE214DA;
	Wed, 26 Jun 2019 23:28:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561591716;
	bh=bvxU9GtnxrSS6JL5vSuxzibwl2B9AdNA5bQBLj2CaHo=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=zmegpjl0RaiGNlS93NVud3hTVj0twmtsxSir+O4KVOYh5+Vxzeaoc1YAvUKF3f2na
	 9F1F4ANmd9ITzobFe0KSzL85XYPqL1ZmzSjigvfJe/ej50so4Sd4RwAxntdbVjEX1/
	 h3edJ8Doi2xX1X0wWnUsOQrr70SVJqduegIQBWf4=
Date: Wed, 26 Jun 2019 16:28:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexander Potapenko <glider@google.com>
Cc: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko
 <mhocko@kernel.org>, James Morris <jmorris@namei.org>, "Serge E. Hallyn"
 <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, Kostya
 Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep
 Patil <sspatil@android.com>, Laura Abbott <labbott@redhat.com>, Randy
 Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, Mark Rutland
 <mark.rutland@arm.com>, Marco Elver <elver@google.com>, Qian Cai
 <cai@lca.pw>, linux-mm@kvack.org, linux-security-module@vger.kernel.org,
 kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-Id: <20190626162835.0947684d36ef01639f969232@linux-foundation.org>
In-Reply-To: <20190626121943.131390-2-glider@google.com>
References: <20190626121943.131390-1-glider@google.com>
	<20190626121943.131390-2-glider@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jun 2019 14:19:42 +0200 Alexander Potapenko <glider@google.com> wrote:

>  v8:
>   - addressed comments by Michal Hocko: revert kernel/kexec_core.c and
>     apply initialization in dma_pool_free()
>   - disable init_on_alloc/init_on_free if slab poisoning or page
>     poisoning are enabled, as requested by Qian Cai
>   - skip the redzone when initializing a freed heap object, as requested
>     by Qian Cai and Kees Cook
>   - use s->offset to address the freeptr (suggested by Kees Cook)
>   - updated the patch description, added Signed-off-by: tag

v8 failed to incorporate 

https://ozlabs.org/~akpm/mmots/broken-out/mm-security-introduce-init_on_alloc=1-and-init_on_free=1-boot-options-fix.patch
and
https://ozlabs.org/~akpm/mmots/broken-out/mm-security-introduce-init_on_alloc=1-and-init_on_free=1-boot-options-fix-2.patch

it's conventional to incorporate such fixes when preparing a new
version of a patch.

