Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF88AC49ED9
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 10:04:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82A37208E4
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 10:04:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="AW5DrAcs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82A37208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19C376B0003; Thu, 12 Sep 2019 06:04:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14C1C6B0005; Thu, 12 Sep 2019 06:04:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 013B56B0006; Thu, 12 Sep 2019 06:04:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0228.hostedemail.com [216.40.44.228])
	by kanga.kvack.org (Postfix) with ESMTP id CECAA6B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 06:04:30 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8262C52D6
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:04:30 +0000 (UTC)
X-FDA: 75925833900.07.bit72_618099a04f24e
X-HE-Tag: bit72_618099a04f24e
X-Filterd-Recvd-Size: 4381
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:04:29 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id u6so23402351edq.6
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:04:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=b/rIExj7B4h6eC4mHl71VjTXyhp29mEK5iBcqAyTdGg=;
        b=AW5DrAcscw4bvqq/1xyyZySmm8GCobspqFQVzbhGGa04IJS4RWFuqH/svrDz92T0rJ
         K84vjWZTjUK563+t6r4w7iO/iBhPPQeFMP0di/DtMFPh1IRbUsKPHJ3Oxc8l5evb5UGg
         AfePbOriyQOkGtZCo4vvVowEroFGCCgqj9163AQu4qax5zQTSWzUA7DX4U0ePAc7Ag1b
         YNopkmk4QhOPStos9FVkKThvkxZGJpYafQ7YApID3mWeXjMS/IPoa/39Gb9v8Bp4qWNP
         38dOKgHwNl/hc/f3HZiPwdImwxrg3FY1wa8H6+gJUDAlPeS/lTDQfuoz83kbyEHNCcC/
         I6tg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=b/rIExj7B4h6eC4mHl71VjTXyhp29mEK5iBcqAyTdGg=;
        b=mvtvlyoagaB7TH5yw9wxKwyEPIMq1Q1XyScrVRrM88B0vspIO5MXcXqTyAtJJbnFln
         4euUDqffzoAXdQLnrqQ2QwphQAe5OMiibv9YbVPQp+yzXRaXl48tZ3aRv3k7eWPoWIMo
         8pyO+1Qm8xRQ91fSAJyBoQKYdQvWY/RjrYPMh6M2py4GCRthxoEiupapcGHa3JOa1LHA
         T24iZFEe19mksED+06icMDyNHKheZHwLpLN+cXMZsLXxhRL/kmERqPT5Amqe+MPpPNQA
         4XuzCcrKiai7D7I+pVN3AXuGlbVY/VjMwgxMV3ej9S6e3yWbnlELLtKobBHT5aG4Wdvf
         v5qA==
X-Gm-Message-State: APjAAAUEaL75pleUGEzJcZVBZQIFk9ts4k1l/90MYJNHvcOIx5BbWaSV
	dQ0tM3D5xDRK6o+cuzo15V+YNQ==
X-Google-Smtp-Source: APXvYqwZKRLCxLDMpIRA2e2Lt7Qp2Tx+uu0MwTEsgXW4u8RcmiXb8xDHTXTU8wLY3dyOy0b9ZYcjmQ==
X-Received: by 2002:a17:906:3583:: with SMTP id o3mr11419151ejb.224.1568282668660;
        Thu, 12 Sep 2019 03:04:28 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id kt24sm2791872ejb.72.2019.09.12.03.04.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Sep 2019 03:04:27 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 2F31C100B4A; Thu, 12 Sep 2019 13:04:29 +0300 (+03)
Date: Thu, 12 Sep 2019 13:04:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yu Zhao <yuzhao@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 3/4] mm: avoid slub allocation while holding list_lock
Message-ID: <20190912100429.fk5er66aostbtvyi@box>
References: <20190912004401.jdemtajrspetk3fh@box>
 <20190912023111.219636-1-yuzhao@google.com>
 <20190912023111.219636-3-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190912023111.219636-3-yuzhao@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 08:31:10PM -0600, Yu Zhao wrote:
> If we are already under list_lock, don't call kmalloc(). Otherwise we
> will run into deadlock because kmalloc() also tries to grab the same
> lock.
> 
> Fixing the problem by using a static bitmap instead.
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

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

