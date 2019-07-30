Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AFE3C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:02:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6E7620659
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:02:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6E7620659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 833AB8E0005; Tue, 30 Jul 2019 16:02:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E4728E0001; Tue, 30 Jul 2019 16:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FA2F8E0005; Tue, 30 Jul 2019 16:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4DF8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 16:02:21 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n1so35900773plk.11
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:02:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=J8G1dOwfZCPE1oEr+SGj2zAsKYngRENBUqfQRu9LSWk=;
        b=ak1sfda5Uegkuq3hKqVKWwO30hiNlBGMHXid1MYcnpihVeF8Gea7yo6OFAuYDNy8GW
         uHjsJJhdhWR4WcZgAXMVasMj4p3fNeUF4ct0R+MoSlviXEJXe616OxZ9lvWB/8PMB4rm
         neXo7Y6hzZKsJKOydan9k+zP+1JFQ0EH0zz2Ok3WvgcSyuH/Y9wjpkq4UCGIGcZf2wHN
         9UFQpYjtJlBXmpnlW89bnE4edExaqISy4fE/FAubQITru4ZtyXFh7iuDpFq+VenP8pQF
         +xXWsxakkOwPUMMjX/4Iuc0rG7E5CfJrK+1Ad9ZDUh+e8W6nCi/lxXwZF44A7hpZqjLx
         +MZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVthqHmUMtPlbiN3a8lZv03ClwCb9boeo/hwFopq9Gnb8F0OGX1
	yf6paeeOAZgP3FJ0mcORK1C6aXSziVA6xkAaFIQeC1F8oetaHyBQKQUeUDBh7yyCrwWB7WDRIHr
	ObGZYnxqB8CZXPfxiWv+ie761S6ss5vplaUVbmO+Aup9r8R5Js2erRrMq1l4M2p6iOw==
X-Received: by 2002:a17:902:694a:: with SMTP id k10mr115648768plt.255.1564516940919;
        Tue, 30 Jul 2019 13:02:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDBXU6uXJtjR+r/1NGdZUNvxdRGrYuO6liHrJRjjVVhDV27du6W+DeAXICy17YDR6cSBNy
X-Received: by 2002:a17:902:694a:: with SMTP id k10mr115648727plt.255.1564516940282;
        Tue, 30 Jul 2019 13:02:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564516940; cv=none;
        d=google.com; s=arc-20160816;
        b=RXgCGBk9jbBsoXxhCyI8lJjhJX7AfE10EBNSQpDBCXP3bLegN/a9GF1M+KlSiRRgga
         icfCvy0Wa0o3+Kk8zPlJy7XgBJUuZFztQsqaQaXbjjfBjRWfXNhLqT4t9+kSs5sZ5ZaI
         LFJCrFwgTriudyp9jDIaSuArCjxqEUvK2SaWYvlxPAwVeL/TZHvJjOlYpzHUq45f4kjj
         9IFzcgLG2EuJswfz9PBh4xGjbtI74aN+vdqG0mwbMijIOmLkVORcUBmdKg43JyX8Xvjt
         Q4quO6z8L32i0iH3W6HcAi/0Hd6ikh7uUBloeCmJFXJ/0/aFRaseqEcNqYqFXBjgjrfo
         outQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=J8G1dOwfZCPE1oEr+SGj2zAsKYngRENBUqfQRu9LSWk=;
        b=x3Zn5krfzXTN9ypbwAV8kutkqHF5yr979zLbKBZbayUjQ2M2n6kOsuj8mkD0YpCH43
         IoDFGdzbSS4VBJDwuIdw4R42RY35ZBF+6qYXRJw9TF3UJa0/3YCYgSuXoWKf0zMbMVEn
         TMcediid6S2BaIA3v70L8REWCbcOJrru7Rt84ZrIDw0CHvU+Gv17qobd41cjl7FmJgeV
         szQZLqo6Deoligt7Mm0gJMAhwzCM0VHseHv89WqMlgHahQea1Tsl8QJ/MbBITUh7A7oR
         OlgWmFRdLpwsPv8VUFSdsQqbz866zWFYT2ftVS7Poc/j5nqvVxcwBp/HF13xxC74EOYj
         DX9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f26si32276380pga.117.2019.07.30.13.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 13:02:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id D2C13333F;
	Tue, 30 Jul 2019 20:02:16 +0000 (UTC)
Date: Tue, 30 Jul 2019 13:02:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko
 <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Qian Cai
 <cai@lca.pw>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-Id: <20190730130215.919b31c19df935cc5f1483e6@linux-foundation.org>
In-Reply-To: <20190727132334.9184-1-catalin.marinas@arm.com>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:

> Add mempool allocations for struct kmemleak_object and
> kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> under memory pressure. Additionally, mask out all the gfp flags passed
> to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> 
> A boot-time tuning parameter (kmemleak.mempool) is added to allow a
> different minimum pool size (defaulting to NR_CPUS * 4).

btw, the checkpatch warnings are valid:

WARNING: usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc
#70: FILE: mm/kmemleak.c:197:
+static int min_object_pool = NR_CPUS * 4;

WARNING: usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc
#71: FILE: mm/kmemleak.c:198:
+static int min_scan_area_pool = NR_CPUS * 1;

There can be situations where NR_CPUS is much larger than
num_possible_cpus().  Can we initialize these tunables within
kmemleak_init()?

