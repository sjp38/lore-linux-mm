Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C88FC10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:13:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A801222DA
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:13:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A801222DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0F738E0005; Thu, 14 Feb 2019 12:13:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBD088E0001; Thu, 14 Feb 2019 12:13:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD3868E0005; Thu, 14 Feb 2019 12:13:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69F938E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:13:32 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id b8so2490312wru.10
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:13:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OpBG4h/Nj4VmKx6rfBl+RnWgxImWBhrruCrw1BAcLS8=;
        b=sbZBvqgei5DuOZYlfSgDvFCXDguUlY97a+V5hHvpGIVElRzpTfhDl9EUYhbFdTTlFL
         1P6nkggeU291LrEavCddieWp4IU6wtCr1AJA/GZeLLSaO8POqDFlwI98NZpIJC8qynAC
         hcj4R+8/DAJiStGY2RoXh+8+0WAmb2H+V0+oXc/4RpuwJNsmoZvDrzBIawpuo62X4bBv
         qMT7FLzCNJ9KcPlEXp8yJfvZuZ9Y5og0k6sF+c071OkzsmUbtMX4b2s8DfMtM0Kege0r
         BjFldpBsz/47rfa3CXUpMXLWnBF/YwIMKYR95nSPx4mOeDLoLgKeZ61q+8J9pQYf033S
         lSPg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: AHQUAublIC878pi/yVjZZ9Uwo3qavlcjjlUEjt5hAvBSD6N/cOvL3mjR
	Dy2lk6kIq6iucD8MHxU33zLK4P1k0v8k/d/Y5uuGfZPgj6DLSHTTi9jwUxWPoqfVMkMT5Nx9Cos
	iRIQMSNmcBI7dkcAz9QZplW9rp9CEmh/qDKrEOXqfZLdXWQOHghWh6g43NLBPwxc=
X-Received: by 2002:adf:8447:: with SMTP id 65mr3503070wrf.328.1550164411949;
        Thu, 14 Feb 2019 09:13:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ+7eCVgPWbFM405wHKBX6hz1S6qHcmhqXn15NGEFouUxawPWbKtsfExPwRn11iKIYMikYX
X-Received: by 2002:adf:8447:: with SMTP id 65mr3503021wrf.328.1550164411121;
        Thu, 14 Feb 2019 09:13:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164411; cv=none;
        d=google.com; s=arc-20160816;
        b=hFQXpRJgq4BAvcelL3Q2saDBjDpPDWBwKzm/0tYKPJHyrEc3YqcmJtHnizpcwv7veZ
         Rwi85OAecI3EB2MeuiMzvCu/hltWUWO+dNihi7zfEtO+k5bhKfgBA/6OsJoASlgPS0YF
         zZsbBHNI1wgulsCTtvORucHE9JCQa2lAh8s+FJ+rW1eXYJzJPMLPHBb8Hgtle37ZnTJn
         BdtdfWONGLz189tqW7+nusH6iNIdUO3kqKQC2y4qzC91mdDykcNUWzomcq/11cVpDAdq
         UFUWG619jRYHSjVzX81EuczqRrkXv4LLfYs6VakqwVloCyzc+7nYXNXo0xusfI94QbVn
         sGIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=OpBG4h/Nj4VmKx6rfBl+RnWgxImWBhrruCrw1BAcLS8=;
        b=wm96BUR1jxdj4j+Ibc8ReCpTvmekJAU5z5hN3BrjJ6uya+Y0mb1cxW+N5PiVHoJTpl
         CKj4aEt8aIPbm0cb9AzcuR+BeW3IbDcRHn5h3sBOrBeaEYEBBYWnROFs21PmVzzkVD/E
         buscFlONN9YaUnZAp0WAAJddTf8SfXdhgyLrwc9LlfGsi6XjpyGG2Rv0bbagken3eYOt
         ZRQoKH1tKcD1390l8y+eESkkfQDqwvvqOqNoAAwwMB47X4cwJ8pONpBSBtXwF1H0W/nV
         7Q8m5YKRHRKDp3y8BBc/8hpLlmSdemUvNOZkLYgIF7s9AMPzh36X5fl1ytyLxbvoWxXT
         50xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id o19si1948621wmc.113.2019.02.14.09.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:13:30 -0800 (PST)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (96-89-128-221-static.hfc.comcastbusiness.net [96.89.128.221])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id CD96614D5ECC8;
	Thu, 14 Feb 2019 09:13:28 -0800 (PST)
Date: Thu, 14 Feb 2019 09:13:28 -0800 (PST)
Message-Id: <20190214.091328.1687361207100252890.davem@davemloft.net>
To: jannh@google.com
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mhocko@suse.com, vbabka@suse.cz,
 pavel.tatashin@microsoft.com, osalvador@suse.de,
 mgorman@techsingularity.net, aaron.lu@intel.com,
 alexander.h.duyck@redhat.com
Subject: Re: [RESEND PATCH net] mm: page_alloc: fix ref bias in
 page_frag_alloc() for 1-byte allocs
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190213214559.125666-1-jannh@google.com>
References: <20190213214559.125666-1-jannh@google.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 14 Feb 2019 09:13:29 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jann Horn <jannh@google.com>
Date: Wed, 13 Feb 2019 22:45:59 +0100

> The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
> number of references that we might need to create in the fastpath later,
> the bump-allocation fastpath only has to modify the non-atomic bias value
> that tracks the number of extra references we hold instead of the atomic
> refcount. The maximum number of allocations we can serve (under the
> assumption that no allocation is made with size 0) is nc->size, so that's
> the bias used.
> 
> However, even when all memory in the allocation has been given away, a
> reference to the page is still held; and in the `offset < 0` slowpath, the
> page may be reused if everyone else has dropped their references.
> This means that the necessary number of references is actually
> `nc->size+1`.
> 
> Luckily, from a quick grep, it looks like the only path that can call
> page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
> requires CAP_NET_ADMIN in the init namespace and is only intended to be
> used for kernel testing and fuzzing.
> 
> To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
> `offset < 0` path, below the virt_to_page() call, and then repeatedly call
> writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
> with a vector consisting of 15 elements containing 1 byte each.
> 
> Signed-off-by: Jann Horn <jannh@google.com>

Applied and queued up for -stable.

