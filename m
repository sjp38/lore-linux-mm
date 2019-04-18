Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81C99C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 23:18:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 371DF214DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 23:18:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IG4p+iPb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 371DF214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B61A6B0003; Thu, 18 Apr 2019 19:18:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93E4D6B0006; Thu, 18 Apr 2019 19:18:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DFFD6B0007; Thu, 18 Apr 2019 19:18:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA3F6B0003
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 19:18:05 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22so2344651plq.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:18:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4+PQ66vk9KRKMNJbABmZKkCe2bugk7ReMnXEdIYwvBI=;
        b=TeBmif/zKQlhElPFozDMrqURrGYf0/TXeGyHlfjncpXqaqoXuzQz+d+I+s7MkaMZT5
         Z7+RQGg9hvw8dzBniJvgvXSEqwvH2MvshLOxA0aQzrWGEN4yjd0D2b2If5l8/MHoTIhg
         t5+G96Pw668V4fzN3hlW2pgE1CGqHtGX1e99QPDgVau/gIIpXeamurAegE+YnSW6L2/V
         UJzTZ4nEXDg6qpX7ml/YN0MED0fUBfYIcbHs+NQDk2QxorzdRI3BuSw+EzfKcVowfGsJ
         wRYO8SjGoO8soBCbiSpc5pCeNqCMrilWk7NhHT2N49qa5pM0hzrq8lJEngIcUNM6Bifx
         dJkg==
X-Gm-Message-State: APjAAAWczf8BgSK1Mg8J3fWBqbIM4Ax7S76Skr/tKuUxuFkbpeH3BZBa
	C40wVPeANWeHmLc9ASO67D/DKuyoHJJ8UiUPVsExEmYzsreAfPupBL3LiXKuGTiessDLcJMCuNh
	suTN4G/RF5lplsIXfwNVFD+s4Qzoi2L1vaXIUfVfQg2fIteIjwUQrL3hGRu0tvrey6A==
X-Received: by 2002:a17:902:42:: with SMTP id 60mr331094pla.79.1555629484578;
        Thu, 18 Apr 2019 16:18:04 -0700 (PDT)
X-Received: by 2002:a17:902:42:: with SMTP id 60mr331051pla.79.1555629483879;
        Thu, 18 Apr 2019 16:18:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555629483; cv=none;
        d=google.com; s=arc-20160816;
        b=iDJpdXpQFka3zl60jU2i0MfbTd3a7yat2803DmLuKPrrwjIRuuRgyv0gTgTuN8YV7H
         N88R3LLhMwD0KuFToEt/MtbBCcu/+SbYMJEw1haz+qYny7zR6GSpIQoBCkYJnUBLXLtf
         pWTvCZbG1hxRoi03fbD6/cbvO2Z+cjqyTZ8uyXHCAvj+Urt+p8Ih6PIbXbID6c6g8eMK
         hkwJEeGKLd3uAQAhzdd/9d+zAF4fnFqmqYszpBmIuqYzpyZsyulkW5o+tkqh19TDNnMg
         HuN/P60ZBJijJy1jAc4ayh/VV6LO1bHU0gwBFIq+jXgI612FJ6eGdZnQGw5p/u5tdTaT
         K7Ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=4+PQ66vk9KRKMNJbABmZKkCe2bugk7ReMnXEdIYwvBI=;
        b=dVGMkApea0nD6HEzdT1zTLgJmot/8m9Qwpozl9Ty45iUkfONP7o/Jg6M+Y6MUqlokU
         NcEmcUmCPPUl33wDVhsN+LXLxeypZwcbbYAyGzWm2H0WPBVaYk7kCBbKxMrFKT5ebdhJ
         2ppo+0b/aZL5WME287HkpYfSkjeZU6dXWgZMEG4onEGkJFMu+klL6ICYkr1i9vqnEb4f
         TnxFZE+cNehNbr8CPFLAnqpQvhMN7VtuBBPyLMh5iX1tIU/Okx70dszndJxxXHH15Xz9
         nXg07DL+h+UYCY3ngTOosE53abPOEIeaKwXnxuvfxtsktOCO3MmPJnDIVQUusELWVwkj
         SQnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IG4p+iPb;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h9sor3591973pgi.30.2019.04.18.16.18.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 16:18:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IG4p+iPb;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=4+PQ66vk9KRKMNJbABmZKkCe2bugk7ReMnXEdIYwvBI=;
        b=IG4p+iPbyNpA5DfvBrjqIkow9ZGDTP4e5I92dn3w4N+2Gm8e1YPVxWOSqMwO7+nfqW
         KBqVgIaOtusZYM2UznQkt1u/GTa/RjF97Tn4CK4aR1XMtWrZUhRrzIwOS+XF41m/caRt
         Xe3qhavnAYKbnXpaZaimmlEHpHTcGXwNM4FVKvkvbVPxecn6SHzy0kXcICSc8ad1qe74
         rpyayAmTDI80FcovexHR4e6OtnoXU+X1oHhxr4Ale5TGMFK+9wM6glimRsoW5xE+csel
         OjNIVFxInhM8hQ3XHhc44Efw+lv1csq6qw/+d/XGUT7NX8QO6SS1hEN/vZww+7g7SGhq
         zTfA==
X-Google-Smtp-Source: APXvYqw4vd2gL8+Fu3zj86IT1o3HvPj5kfYzJY4yaXJLzb8gGzdXkUH13mg1+4utQSv2fmW4Y0T3iA==
X-Received: by 2002:a65:5189:: with SMTP id h9mr637421pgq.304.1555629483663;
        Thu, 18 Apr 2019 16:18:03 -0700 (PDT)
Received: from ?IPv6:2620:15c:2c1:200:55c7:81e6:c7d8:94b? ([2620:15c:2c1:200:55c7:81e6:c7d8:94b])
        by smtp.gmail.com with ESMTPSA id g4sm4832243pfm.115.2019.04.18.16.18.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 16:18:02 -0700 (PDT)
Subject: Re: [PATCH v4 1/2] mm: refactor __vunmap() to avoid duplicated call
 to find_vm_area()
To: Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>
Cc: Roman Gushchin <guroan@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kernel-team@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>,
 Roman Gushchin <guro@fb.com>, Christoph Hellwig <hch@lst.de>,
 Joel Fernandes <joelaf@google.com>
References: <20190417194002.12369-1-guro@fb.com>
 <20190417194002.12369-2-guro@fb.com>
 <20190417145827.8b1c83bf22de8ba514f157e3@linux-foundation.org>
 <20190418111834.GE7751@bombadil.infradead.org>
 <20190418152431.c583ef892a8028c662db3e6a@linux-foundation.org>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <05c40b0b-3621-6c07-346b-478679949d92@gmail.com>
Date: Thu, 18 Apr 2019 16:17:59 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190418152431.c583ef892a8028c662db3e6a@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/18/2019 03:24 PM, Andrew Morton wrote:

> afaict, vfree() will only do a mutex_trylock() in
> try_purge_vmap_area_lazy().  So does vfree actually sleep in any
> situation?  Whether or not local interrupts are enabled?

We would be in a big trouble if vfree() could potentially sleep...

Random example : __free_fdtable() called from rcu callback.

