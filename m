Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6500EC004C9
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 06:59:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32EAB2087F
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 06:59:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32EAB2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3C196B0003; Fri,  3 May 2019 02:59:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AED0B6B0005; Fri,  3 May 2019 02:59:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DB4A6B0007; Fri,  3 May 2019 02:59:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7395B6B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 02:59:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f64so2594516pfb.11
        for <linux-mm@kvack.org>; Thu, 02 May 2019 23:59:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:in-reply-to:to
         :from:cc:subject:message-id:date;
        bh=VliTphK8d2uY++B+00kx4b2yo/8La2sjNa+6+heMhZQ=;
        b=fiRGA2iHHZZ5ou5WE4E6MkqbzWGADdnHJD5oCHsj9xWKKSksAU6KrSpqBbIYE9PFWW
         fgwgX3lBu31qBNoX5zQno+g8TqS3m85z857jA9Y7S1x78YX9iOdZW1u4atYp1/juDheW
         v/VOZu8q4hyAgf+sz1RJvj4QwkhLcdOGbAS+qn0oV39rG5U7VCTT6jFqlKKSqB+aG4Oi
         dT4BzknpdzZMlFOHguI0RH8m7tjD4FVHfVwBSV6ADZW+fuAlVwrZE8a6BA7xk44/aHV3
         376gpxi497d7uNkO1/FAjR/GDkpdUMbrmdzrjjtJKV515wx/7HRH6aw9Y7PCWVNSKpUJ
         gdOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=michael@ozlabs.org
X-Gm-Message-State: APjAAAXFKWu5ZRyaF9cfmx2VS+2C9bnsqcviTsWtW3qUsEKmcMxOCqZp
	iQSFZEdfUmDs9Bs7AXirQq23586dr/PGY/Jp1jtwp40vvpnBVGFLn9KQXIOH3/HkJNRTdbU9CHf
	SRmzXV6+RrXw/AGNa1ZpjIW5YkWBrryMooK6MZkWwgKef7X6OS9iG+xWPA0P8IQI=
X-Received: by 2002:a17:902:42a5:: with SMTP id h34mr2858413pld.146.1556866768144;
        Thu, 02 May 2019 23:59:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvLsVwlbO2SkTNDJjIcG1IEv44IfYNu8XN2M4FQkBCGHgtbSrjvvBtFZZtELosFcyOwrcG
X-Received: by 2002:a17:902:42a5:: with SMTP id h34mr2858374pld.146.1556866767487;
        Thu, 02 May 2019 23:59:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556866767; cv=none;
        d=google.com; s=arc-20160816;
        b=0DCW6KoFXahx7RIwovvqs86MsbU74uGoAR/9J4pkfxiHYFPKbEAuryBFo2TcvStMK5
         40tGyDDQQFo1EBzhZcpXNacUDlw+o+gRJdTWs1k5bCKWa33OehPQVUOO+E4/A47QFoX+
         1l6uUYGX78cAd4UQspVvv0Av3MVJZMYYjVJkiYhryusqFGRIYuM8A+2VJ3qXjb5/dZJ4
         OSymdG5B6inbYHT96f1C7Max1732Qq+yOUc9tOekhmORFmLRQJ0nRE9iDwPqZ2ZiD3iz
         yb/pvQRUgIO6sUQD6986Zj+Xkqrhgt26bitZZ0eAtOickewUFBFofyhtCNHWio2TWuAU
         P4NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:message-id:subject:cc:from:to:in-reply-to;
        bh=VliTphK8d2uY++B+00kx4b2yo/8La2sjNa+6+heMhZQ=;
        b=O0s5Oc14IfOhwUrGfr0o1tPaEwUEOdvlFYhI3bZIuspT9yJOAcsUptVnwF0RjkGNA4
         caiBs2h365GKLMkruSFYvQx72/DoeCwrNiiHswMW8SXci9uS9iTlF4F+4AlPlqwjmpjT
         TJyLNuzPBTSizB8mM5V3pnF1/nc8Y9NbhmGH4NHlgzo+GiCp4Oz130LJ52z5MPm4Fa1G
         47aOnM/NhFtSfVS+2hlO41d0rVc/Ve1hf259sTsUaUaTf7jdwIEeAWGJwsXvHFE+NBP1
         QCvBavBYu1T6uq8EUMUriPIGl5aJCgDNHQ0yXFBb/fHhsoU1VmMs9wpuM/zMnY+0F1zg
         599g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=michael@ozlabs.org
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id e15si1199868pgm.377.2019.05.02.23.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 May 2019 23:59:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=michael@ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1034)
	id 44wNKS6JSsz9sPW; Fri,  3 May 2019 16:59:24 +1000 (AEST)
X-powerpc-patch-notification: thanks
X-powerpc-patch-commit: d69ca6bab39e84a84781535b977c7e62c8f84d37
X-Patchwork-Hint: ignore
In-Reply-To: <08b3159b2094581c71e002dec1865e99e08e2320.1556295459.git.christophe.leroy@c-s.fr>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com
Subject: Re: [PATCH v11 01/13] powerpc/32: Move early_init() in a separate file
Message-Id: <44wNKS6JSsz9sPW@ozlabs.org>
Date: Fri,  3 May 2019 16:59:24 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-04-26 at 16:23:25 UTC, Christophe Leroy wrote:
> In preparation of KASAN, move early_init() into a separate
> file in order to allow deactivation of KASAN for that function.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Series applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/d69ca6bab39e84a84781535b977c7e62

cheers

