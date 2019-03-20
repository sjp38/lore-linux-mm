Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF33BC10F0D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:48:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF1082146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:48:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF1082146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CBE86B0003; Wed, 20 Mar 2019 14:48:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 359C06B0006; Wed, 20 Mar 2019 14:48:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2440A6B0007; Wed, 20 Mar 2019 14:48:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D99CC6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:48:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 41so1296404edr.19
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:48:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Aj/YWbUIlUK1XmZv4Ol/+2hNlNhnNBxVkAGpleoPK9I=;
        b=uaC4IMHa1UGGVUWUUQ8ZQq5+zDLQcQqjLav/XtNIRrzV3KvO2KElYtX/GPPPaRdWnO
         W3JHlaSVfqYf0/kFLGfj7YaEO+QimNml5X+FAP6dBYrVdDTQqd3kE6j32JFDw+A93oBY
         HqT2XK1XsCoKoPg+1xzz4ZdxwUvuVTkLghZANFY/dfBMh7oru5yrkSVlufeWIDgchJXz
         BTPVvPbxnAf2Nzqpaqipz1VHGOYbABLmmwXGBNmhHGqUgiknhF0iXUKS5ZQqiD1+YaRR
         7d/fiFXv4eqg/piYhCD7c1W2Go8kcMKHKFkVjJHXuJQoe5MIc5pIfWVULWgnXunrJejl
         dZeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVmm8yQrTHLovTYHsmi4FcY2cXcaTCEKFM/uoXh4RIRihBgrVFD
	LSgMF9NVrRvI2+qoMv9P5qqmDVkgVh1Ceo0ODuTx9C9BDhmZyGsz21zr63gbQAWHl6NRLFjdhZ7
	gDnywj45/qovqEjjLVb79EV89P0QTDLSVkG0pd7vJ+Y7rt0V38lGXzUCupKD1phSbDA==
X-Received: by 2002:a50:b8e2:: with SMTP id l89mr21490740ede.140.1553107732465;
        Wed, 20 Mar 2019 11:48:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBYdTZmqGjlFLOg27zhBf0cshutu0YpFFDd7XeO92y5qYtLVECd0OCLLDc6k2q5gQ3I+/x
X-Received: by 2002:a50:b8e2:: with SMTP id l89mr21490715ede.140.1553107731567;
        Wed, 20 Mar 2019 11:48:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553107731; cv=none;
        d=google.com; s=arc-20160816;
        b=Or0po1YqQLCa/7JCUonWU3RgFmbt5rf228WvpkSLmlPZKICzSoBoVpYlJqJxxtXRNM
         h2cEv1I6RFT1keV8/E0nROH+r/ObUB+CRYgGMGnv+PnqVw19+CRoOae24JZjdEkKvAGM
         q6v5WBvOIQi8mrPdyKA2eM/D98iNRI9JfUy1cn0l58iQHNSxbDAhvWMeXllx0SOln0um
         xvRy3sb8M9xm2cE6UmTHYOYfkbOt0bk0OoEn8RFavLo2B2aF+/yxEyVQP99cO+IF14nF
         Qyl/Pg2wv4fRK4hFBZ6rw2nfrvARh5xQwJarmj/bTP2GJ7/1gL3GKKemar/E6NmrSdRg
         11hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=Aj/YWbUIlUK1XmZv4Ol/+2hNlNhnNBxVkAGpleoPK9I=;
        b=ZZ3eTZ2B3VtsXqaU+eZb2tcQ3+4x0Xq516ahlz6EkIEQHHQzAmefnvgGIjCZqT6cTP
         0oAzld19waIKvqnDmlXuDegJN31l/7pm1j/RlYvdr+wOl/7jyAhJIDAGWHYBczToLjLH
         wd/A//lczr4QIOzAaqCwVpboe3MhfUJy1muJpWk7S2f6nwVbliu5KhHofOSNuSYIR8WM
         RcHJSvrgg+FLRzJVpYbrVKP9SUAQtkMocrZUaXJPxNlnp/gLljHRhZEY3NhJniMMiP8n
         iFImZfo3bUJRV69Uc/+JKlk+8oYAsmjoIgvG6yA0G0E0/n9Bl+4ZfRRt60tvDW3ykImP
         OpDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t25si868031ejt.245.2019.03.20.11.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 11:48:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B22A6AFBF;
	Wed, 20 Mar 2019 18:48:50 +0000 (UTC)
Message-ID: <1553107714.2927.2.camel@suse.de>
Subject: Re: [PATCH] mm: mempolicy: make mbind() return -EIO when
 MPOL_MF_STRICT is specified
From: Oscar Salvador <osalvador@suse.de>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: chrubis@suse.cz, vbabka@suse.cz, kirill@shutemov.name, 
	akpm@linux-foundation.org, stable@vger.kernel.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Wed, 20 Mar 2019 19:48:34 +0100
In-Reply-To: <3c880e88-6eb7-cd6d-fbf3-394b89355e10@linux.alibaba.com>
References: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
	 <20190320081643.3c4m5tec5vx653sn@d104.suse.de>
	 <3c880e88-6eb7-cd6d-fbf3-394b89355e10@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-03-20 at 11:31 -0700, Yang Shi wrote:
> No, this is not correct. queue_pages_pmd() may return 0, which means
> THP 
> gets split. If it returns 0 the code should just fall through instead
> of 
> returning.

Right, I overlooked that.

> It sounds not correct to me. We need check if there is existing page
> on 
> the node which is not allowed by the policy. This is what 
> queue_pages_required() does.

Bleh, I guess it was too early in the morning.
That is the whole point of it actually, so that was quite wrong.

Sorry for trying to mislead you ;-)

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

