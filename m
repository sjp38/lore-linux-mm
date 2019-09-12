Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 590FDC5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 00:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C31C20872
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 00:44:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="1YIRu7OB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C31C20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A91D86B000A; Wed, 11 Sep 2019 20:44:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1B296B0275; Wed, 11 Sep 2019 20:44:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E7DD6B027C; Wed, 11 Sep 2019 20:44:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id 6676A6B000A
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 20:44:03 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id DC8C78786
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 00:44:02 +0000 (UTC)
X-FDA: 75924421524.17.way20_629d485f0456
X-HE-Tag: way20_629d485f0456
X-Filterd-Recvd-Size: 4050
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 00:44:02 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id c20so13345487eds.1
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 17:44:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6StUCxf+BWs9paiGrgjzm2Rs3EDZa4/BKSwVoScmogM=;
        b=1YIRu7OBWjHb8fUC4OZsQnAZgF+XMXsYulmcYNiwsD9u1wQ8+Utdc1dw+m66iuQdix
         v5p81DWC0EjIhrdOnyRFKeqr5rM/g3udJ6VSr1MasKrLYYkh3Z4RzAF3qYUxsmA2Gnlc
         N4GHSmsEAARs3WKCX7kEct9w976BVLZXa6PkGWm4NZFKsMo7VyjuhEJCNBOWW5jc9KEJ
         vHFzHJznDAECzPgjTfQ8E23aVgbLlyG1AbpmrBx34xi0WwzzawqOkcfkQm0jqtr3FedN
         vUFDJiEZh58lxtic/ZjYeSEGnfQv/9tSJqml56+sMByvXjeASfUxcLOWfM6EzLF6sg0n
         6o8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=6StUCxf+BWs9paiGrgjzm2Rs3EDZa4/BKSwVoScmogM=;
        b=cbMkYTUoXCHTSbLKfKhp2F5NysdLfoE4tcfLBlI/er8JNHo0TTGDOn0L7ZLtc6pELv
         NQusaK4+FWLBLA8kEVjYplJEIIpiVf7MmcNpgPgCrzk3PQCLWj9cHWtn4r0sXjv5Gco3
         eqIjBPsJt6jYMULfhqPYFmlWbxal8rjj7HqiIoJ5gdJA8GTiIMmay3mVUI3Xiw9x5MZk
         hIAxPx8XeHqI9t6/4oWmJGK4w5th3QVdjrMPJeu+imGT0KoqebdtnDfAb8v9e7M/Sh0F
         AXVsxrO/tGxAL8odPV0uSh7WCFeIADw81g4ahBOsixPc7yJwWbgvB1qvd7OMk1FEuSiu
         PWSA==
X-Gm-Message-State: APjAAAX1BAJspRvKqGnsMahQtfsCf6lm3I3rKXS5KOVJV4M2yjfZH3wL
	44Kt7fkkAscHk3sUSrFYHOOGLA==
X-Google-Smtp-Source: APXvYqzi7ktkOl27RjHC7fqkd1PP4Q4XGWiLksyI41yH4eDgMgZtb4qs2+CSjrzffnaM6EtMV1Zp4Q==
X-Received: by 2002:a17:906:d922:: with SMTP id rn2mr31668293ejb.169.1568249041020;
        Wed, 11 Sep 2019 17:44:01 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id b36sm4490966edc.53.2019.09.11.17.44.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Sep 2019 17:44:00 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 58DAF101601; Thu, 12 Sep 2019 03:44:01 +0300 (+03)
Date: Thu, 12 Sep 2019 03:44:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yu Zhao <yuzhao@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm: avoid slub allocation while holding list_lock
Message-ID: <20190912004401.jdemtajrspetk3fh@box>
References: <20190911071331.770ecddff6a085330bf2b5f2@linux-foundation.org>
 <20190912002929.78873-1-yuzhao@google.com>
 <20190912002929.78873-2-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190912002929.78873-2-yuzhao@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 06:29:28PM -0600, Yu Zhao wrote:
> If we are already under list_lock, don't call kmalloc(). Otherwise we
> will run into deadlock because kmalloc() also tries to grab the same
> lock.
> 
> Instead, statically allocate bitmap in struct kmem_cache_node. Given
> currently page->objects has 15 bits, we bloat the per-node struct by
> 4K. So we waste some memory but only do so when slub debug is on.

Why not have single page total protected by a lock?

Listing object from two pages at the same time doesn't make sense anyway.
Cuncurent validating is not something sane to do.

-- 
 Kirill A. Shutemov

