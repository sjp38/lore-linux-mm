Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E047C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:23:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 620C1217D4
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:23:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wiPm2VBf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 620C1217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F33C66B0272; Wed, 29 May 2019 00:22:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE47B6B0273; Wed, 29 May 2019 00:22:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD2F56B0275; Wed, 29 May 2019 00:22:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B696A6B0272
	for <linux-mm@kvack.org>; Wed, 29 May 2019 00:22:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e16so842232pga.4
        for <linux-mm@kvack.org>; Tue, 28 May 2019 21:22:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1WJx1Oa5eifOrBv2vLYoGQZKOm10m5HgsaTlhuWP6o4=;
        b=AookLq5InBVAuwdRyyDOJdyBc2Dzr8v8iq2tYZzokiiSneslxsK3UPXKnlj4w5RJZc
         Gp9UHG5s68IcgW3mKNVMDix3dwuh8HTdznvoYl008sk/eJwegX+ZoNqd5jnPOCuGlIQT
         Vj/hkOK8tv8bbp6wAJiAr/41ffaW3psaelGyPTAunIJJORt1WxaNsnB5447YFpV5JEAo
         GjP2GPRFjmmLZWaBQsSwn5innb8XilHz6CVnvoAXk9dZTYPUu/y9GoY3frEbxHYLNrbx
         b5lkgKZlrMe6rfKQUmj0hiJYyaIsuv+z4Roaoqg2fHDKBp+z+r0VaUYQHezC4viyb1WJ
         VzEA==
X-Gm-Message-State: APjAAAUKUm5Vb1Xv5AZVIoYR+pIGvUfjhfxKF/VX3C7D1kDZIJcYwPv/
	ChysnE2DAYetB4rkHTlQ2z23Z9C873UMWmZFsE6yDEWu0uSN8FkuiOmcenMQR0BRfOs22bVQ8N0
	CJlkCEo08XPwhHGFV47Et1terVqJvNrjlaqe/xOTjjvrso3RiVv/btcTJNtVIDlJiMw==
X-Received: by 2002:a62:ac0a:: with SMTP id v10mr145787798pfe.57.1559103779423;
        Tue, 28 May 2019 21:22:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkUNKX7s/XNtve//WxR+WGele00044LKBoKjs8EYWUB1sVEhDlmw6nuJ47i3fz/KwpQPjV
X-Received: by 2002:a62:ac0a:: with SMTP id v10mr145787765pfe.57.1559103778744;
        Tue, 28 May 2019 21:22:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559103778; cv=none;
        d=google.com; s=arc-20160816;
        b=fAbos8FrMOP4B+0E87c2xfUq5Hf/31UcRfvOQPjyN/7L2NgC39Gwu8OmkEgwwEoh4C
         7RrPjv9dvbBw76KJixOacJIZkr1RCJviQFocjxkKWHaP6cHMF7rnf6x8NC172YKlxAzx
         qrZy+L4cRD74x15cA6HBjzGttr3DGcm3d1rEqEq7wkbYVu2r8m2bHdNjiTWF5+iIneIA
         GyceJ1ZDrj7Lyd9M/+kbug3oRgUbRYOhaKK1XnsAQedXkOav/qmss8DE4eiLopm7vRBx
         HrnVxlN0PtwYsi2bJs736x0Raag1DzgF/npyVl+Jdyr1gKUiDhR6MV4FXJYha5aoZnDV
         p2Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1WJx1Oa5eifOrBv2vLYoGQZKOm10m5HgsaTlhuWP6o4=;
        b=aUO42jWICDKmorE8A0WN9hvFgMwN1BlfX077KAFutQFe9bWf0W2iVDHq8sJty+iuME
         JIO0RylmAfp149DVh2pzk2Z3mQfwmDun3l83Kq8mBe1S35okEpuOP8vISsQ9G6JyEzHr
         ZXbb2buWUlSvG21Pud5HaWfd02JyKhfrTAGEEWfAypDmVwMJmlfOO4JO9c/t4rFONeVu
         L3eCbLDvPoWK5Mp19QVfjecXHe4KEQCJ8AhoDZqzDEvrUY1UIRYZbHba9sDY6r+TjDyE
         Hk2uxSzKxxKM82ODN4kh1ql0PkjfX4kUA/zjXTnTzOIoFYd6orLrT0MX9507vyVpHNnB
         XkrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wiPm2VBf;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s14si27603161pfc.146.2019.05.28.21.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 21:22:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wiPm2VBf;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1CBAB21721;
	Wed, 29 May 2019 04:22:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559103778;
	bh=ATkAsEQTPuRxR/DSpBomoHxEEknaKNBHYQxPeUoQLo4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=wiPm2VBf7OzA1rzusz946gfE/ry9tgCt8yTlZVIqC9ceio38Y2matL1H7dtUfCkjt
	 HP6dVWadrf4PdtYOyRNNieiZ8p0MxP9wM00VqUiiooNEz69ibmdhhc0ggKC7BHnoOi
	 DkIUfTUX0eH0kBFp6yWFDHOJloK5GW/LKO95GIWA=
Date: Tue, 28 May 2019 21:22:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Johannes
 Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yang Shi
 <yang.shi@linux.alibaba.com>
Subject: Re: [PATCH] mm: vmscan: Add warn on inadvertently reclaiming mapped
 page
Message-Id: <20190528212257.f795b405ac1b88d72bb3fa2f@linux-foundation.org>
In-Reply-To: <20190526062353.14684-1-hdanton@sina.com>
References: <20190526062353.14684-1-hdanton@sina.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000034, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 26 May 2019 14:23:53 +0800 Hillf Danton <hdanton@sina.com> wrote:

> In the function isolate_lru_pages(), we check scan_control::may_unmap and set
> isolation mode accordingly in order to not isolate from the lru list any page
> that does not match the isolation mode. For example, we should skip all sill
> mapped pages if isolation mode is set to be ISOLATE_UNMAPPED.
> 
> So complain, while scanning the isolated pages, about the very unlikely event
> that we hit a mapped page that we should never have isolated. Note no change
> is added in the current scanning behavior without VM debug configured.

The patch is inoffensive enough, but one wonders what inspired it.  Do
you have reason to believe that this will trigger?

