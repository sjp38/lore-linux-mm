Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1E5AC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 19:01:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C3BF218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 19:01:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C3BF218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 429C96B0003; Tue, 23 Apr 2019 15:01:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 401346B0005; Tue, 23 Apr 2019 15:01:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33D996B0007; Tue, 23 Apr 2019 15:01:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3556B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 15:01:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r13so10569497pga.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:01:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pIiKOOgCR/TNxE6yXzwzJFRERUw2hVqbz11aHRTY6RU=;
        b=VazqDXjABPSJW7KpixThsVO1Vx9g80yaoZz+kQUwib8giNdXVQmsyAYtlQd7J+F1vJ
         Pq7JanNLEcOZ4ZQiNy/iK7i5rvQeV0c99AZ5E5D9UjdnYq18fpJlofgoWM8eUUjP3+yy
         sK9sh7DZt5/fkfJ85+y9ycoW3nw+tGQAHxSPD10JeuGYUQB1H9Siy6mshcw/cKRyxERx
         NR6Nu4GYtSmKpmN6YluGwRG0am4bznIRB9Ofo381Hgu6BhlzC696A3ywot7oQPopGTc9
         ewws7DPoTcZhzGWr5Denm2DOtkDq0+2GeYpOCX+aVyOvfj4sWZzhJ+9IsiNTuTOKbiUZ
         NfpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWRfKGTiOLerCtLAOkNKZetwJo4qWVXsp6A6bxzwNw7a3YMT9Kg
	ib9hmmCUqBA6qDXpHxqR+C0U0wc9xiAtsEAWagJ5rcZdLUX0sgNBt9QMugfCrudWYtRYgIgT4K5
	tmytr/q89jXy4FqN/uZcmRy5drS5VvUhMddtUofOHtM4lz8+apPbF4iV/IlTE0FY5wA==
X-Received: by 2002:a62:7603:: with SMTP id r3mr28744463pfc.32.1556046106698;
        Tue, 23 Apr 2019 12:01:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbDsCr0SX0+HwduD2kW+c0fC09g1Q2RVoeYQtz4q9fDG5iwC5s+yiZNkdbmr2uVzjXvHg0
X-Received: by 2002:a62:7603:: with SMTP id r3mr28744391pfc.32.1556046105863;
        Tue, 23 Apr 2019 12:01:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556046105; cv=none;
        d=google.com; s=arc-20160816;
        b=esERuL35Tr+9M5y0QIjPdsJLAcYvESxALid3HQ+sUdVzUZq9mHbjxu45m41jRGHSc8
         2kkCf1uPzONE+/PqBbXwDSZBAXc1mtiXTynm4ZpyxzUl3Yg7DA4lAMySHv1NYHwxvMWl
         vALN007LuIPs0tGONBFgHD1Euzj9psYIQwYETwfRY7QFICvCyGRGiSQv6c9CMaOyRD6N
         zwPk9Z4Ty/YkZS9DCkYaI0VemNXSsOeVspk4EAbzXfCFI9Xj8CZvpH1MYKARvXAKNJXr
         odZkaSOs3kCjA8wK8Y25nUSi4JRnaM0Jh9mCy3blB9VDw76sjkvxzKWmNVpei+3iXTd3
         gvJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=pIiKOOgCR/TNxE6yXzwzJFRERUw2hVqbz11aHRTY6RU=;
        b=mJEmPPSxUCChbFNYrq+CnATr/IhyxnN5s7N98WV3i7kRVELgdb72s6qP0lrVxDgQFa
         C1GqHj6z1rFK5yUJMr9A17GHMFdXskv9kRQEUk/+WpzcKjR103cE3UgnVI4yxMI9BFBJ
         x0EbqhbYQeU0mMDjxmM/JOHTxEA2BhExvqZLqVYQIqkHmO0BPMN9l8PjQSUcgobvsCdj
         sfLqNA6T/+Xp/N27iFL670cG1gTQZW0efBAqWr8JX0/k9tj9wLbpyyxKCWss3C7pSHi9
         uxCrhv9iFC3cjPI0QHIQeTfifpfhWr62QYEN5xnzkwO+nEyH8geCLx7ItGtWMfhDIjaW
         FB3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f9si14985809pgv.475.2019.04.23.12.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 12:01:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 52444E1A;
	Tue, 23 Apr 2019 19:01:45 +0000 (UTC)
Date: Tue, 23 Apr 2019 12:01:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm/page_alloc: fix never set ALLOC_NOFRAGMENT flag
Message-Id: <20190423120143.f555f77df02a266ba2a7f1fc@linux-foundation.org>
In-Reply-To: <20190423120806.3503-2-aryabinin@virtuozzo.com>
References: <20190423120806.3503-1-aryabinin@virtuozzo.com>
	<20190423120806.3503-2-aryabinin@virtuozzo.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Apr 2019 15:08:06 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> Commit 0a79cdad5eb2 ("mm: use alloc_flags to record if kswapd can wake")
> removed setting of the ALLOC_NOFRAGMENT flag. Bring it back.

What are the runtime effects of this fix?

