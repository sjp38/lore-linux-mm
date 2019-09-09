Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EF59C49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:00:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D79FF20863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:00:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="xUhNbtb8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D79FF20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 598326B0005; Mon,  9 Sep 2019 12:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 520CC6B0006; Mon,  9 Sep 2019 12:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4182E6B0007; Mon,  9 Sep 2019 12:00:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4146B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:00:57 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C3FFD8243770
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:00:56 +0000 (UTC)
X-FDA: 75915845712.11.cow46_7c99f9b57bb46
X-HE-Tag: cow46_7c99f9b57bb46
X-Filterd-Recvd-Size: 4370
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:00:56 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id f2so7096577edw.3
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 09:00:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CFK1lbGHffDm6umuM9k3uT7cdf40jo8hdVkVwtcY2GY=;
        b=xUhNbtb86aVkAx3yfWip/bShT1PRDlmu68HwjTSCKcyChoYWBFNqtiTj5YLOV2fRw4
         DZFuTG9sDIyndJxyuR44cobnRO6ty5IQ8eTAx0v07Ss/uSEqyIFEt+X9QvMaYzI5qkxC
         NiZSua7Sf//B63lXA8gRAJexdeAHzk8Azpnhy9e/n9BXG/GfL6cfytmP2l46amtBg1td
         QA2PzGBw/D+tegK8OKSbMqntzXJpo5ca7S7yKauQEinx+bZ5lPT/300tIha6SJAHXTfN
         ZbbLwqe0MfWDdb7H19gfXghj7RoWSai5/QfrsGWtEYdTaOp7+dOx9ptJs87f6MraLnAg
         kcxg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=CFK1lbGHffDm6umuM9k3uT7cdf40jo8hdVkVwtcY2GY=;
        b=WaGpBpNPAKuZa0gqrtBS8jG638Lhcbqob1cXzdDiLG30Fgnd9VrDGLRebVXWn4AqU1
         3VaLuDDIQqSXof4khzFMU3ylRBXIBgxMddPjyErKMXLjEAW+evbCrrye/Pc88uyC1JMy
         3SlwvJmiKlhWxf+ae0wVCaSfoFxsuqUiVkgoNTW/SbvRrnHFuQ6dAN/I72vk3/8op9iO
         qOpNnzWqQkpHoVd6+k6VoDUVVovaDGQ4TSGxGXsKeeEWEP4/4G7DnCnfhbBXSLK5MZvh
         UH52BlS3PCqecvSYaORs9aAYAFOS/l/lN5kCsQ0gP8lPaLTlkm+xjUT50wUQRGMsn1eM
         6dUw==
X-Gm-Message-State: APjAAAUBMJRWJmvtLf9dwRpm4acojoox6ear0mVIibVFoN4voep4wjUL
	B1h3JZDhcUv4/rddSKa31jq/yg==
X-Google-Smtp-Source: APXvYqx83SYfaQIZNNdqeTrgytehrdeUAFD5eiOanG1H+SCZAn2dIW5NEvmeLWTKygMcElxeZFvigA==
X-Received: by 2002:a17:906:c401:: with SMTP id u1mr20456482ejz.254.1568044854982;
        Mon, 09 Sep 2019 09:00:54 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id z26sm1802345ejb.51.2019.09.09.09.00.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 09:00:54 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id E70B81003B5; Mon,  9 Sep 2019 19:00:52 +0300 (+03)
Date: Mon, 9 Sep 2019 19:00:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yu Zhao <yuzhao@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: avoid slub allocation while holding list_lock
Message-ID: <20190909160052.cxpfdmnrqucsilz2@box>
References: <20190909061016.173927-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190909061016.173927-1-yuzhao@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2019 at 12:10:16AM -0600, Yu Zhao wrote:
> If we are already under list_lock, don't call kmalloc(). Otherwise we
> will run into deadlock because kmalloc() also tries to grab the same
> lock.
> 
> Instead, allocate pages directly. Given currently page->objects has
> 15 bits, we only need 1 page. We may waste some memory but we only do
> so when slub debug is on.
> 
>   WARNING: possible recursive locking detected
>   --------------------------------------------
>   mount-encrypted/4921 is trying to acquire lock:
>   (&(&n->list_lock)->rlock){-.-.}, at: ___slab_alloc+0x104/0x437
> 
>   but task is already holding lock:
>   (&(&n->list_lock)->rlock){-.-.}, at: __kmem_cache_shutdown+0x81/0x3cb
> 
>   other info that might help us debug this:
>    Possible unsafe locking scenario:
> 
>          CPU0
>          ----
>     lock(&(&n->list_lock)->rlock);
>     lock(&(&n->list_lock)->rlock);
> 
>    *** DEADLOCK ***
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>

Looks sane to me:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

