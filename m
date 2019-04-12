Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5831C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A213820850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:16:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="eumZZKoB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A213820850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 309CC6B026B; Fri, 12 Apr 2019 10:16:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B7F06B026C; Fri, 12 Apr 2019 10:16:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CE766B026D; Fri, 12 Apr 2019 10:16:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id F07B16B026B
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:16:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id g25so8011666qkm.22
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:16:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=BNfbrBu7Kf9YbRjnRfGu2WkpXEstm8Do5o3zkCQBOsE=;
        b=Fgj0/opD4PVwIBSIULbBDwzDMZ5qD9hfAzc48a/KE2ZvmYRYo44Ng5EpmmWusnIYhN
         a91uMHRI6s4wBlD01tr1msx9eLRzz4m/4If6EV4a9rdzfNg3WYuBPxiMxZ/VjZ29A9SN
         a9FzBsaOEaqYK/rMPZoh94KwjvFPY9WVWca0EXXbB6GrEfGVhLF3oEFn4UMeTOyZGinv
         F5rKlTFOIDJg8zOUY07jnLZJT6ZZyirCgYDwTLtCPP0RqmePTN7IoaAsvYFiNKgjDNdn
         hh+y1+xi8lXveraCcuYTmWi0MdECgC400z+9jlYMlC/On0ktoGtCCbWInPktzBE5R5cM
         2nwA==
X-Gm-Message-State: APjAAAUHMCMgA4kwGlqq9uH1Y9x6Ei3yJVK02Vw3O/YOHAOkDY9DCQLQ
	3DBJwh4vNtWNUezEM6N1TTCNzFt4VIig6utOt6PePCwB68ddynzbDyy7r5QH2eDLN8hAZ9X1l3O
	/hYiBjMouVaynAi6BZTRa9zefpgm02M2Yah09NWckdDmTbIWDplhuG2aJoQrgfFE/uQ==
X-Received: by 2002:a0c:ba2f:: with SMTP id w47mr45749270qvf.72.1555078587713;
        Fri, 12 Apr 2019 07:16:27 -0700 (PDT)
X-Received: by 2002:a0c:ba2f:: with SMTP id w47mr45749212qvf.72.1555078587108;
        Fri, 12 Apr 2019 07:16:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555078587; cv=none;
        d=google.com; s=arc-20160816;
        b=tHWOgrE8NtdyrX99UJsJiFDx7Zv8ZSHtHATlJVfcZTRbJ4mrRDrmObeMA4wdi6w1jw
         4yargdBjJDuSYopCtn87XGZErULdBaC+rXhsdvSgGTo0sdxQp6c8i48+1jilHDI2c3AL
         7f/h8A2qjnjI4/1uXPZTXKZUs50eURzehq8/Qn4IJ/DcP13JDto7+y84iXebm/JtBc+7
         iwmqJ/dbkne6MsLhkQIMTWzE1sphj980qKd3NxoaHUq2/2BTB9RbuuPBho2ZEgQ1f1yF
         A9jKKnkM8/s8ttwieTolJOUsgoBX/aPb9BBxuTez+lhZVllZwZIHrijTjbrSn/jUP+2X
         XIZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=BNfbrBu7Kf9YbRjnRfGu2WkpXEstm8Do5o3zkCQBOsE=;
        b=a2CO3kbWPL1Zg3kZenBoZdKxUbehQr/IBjNU2TPhDRLYqa973m3Y2Kk7j7Rkt83bFM
         fQceUKry6vmW12lIdz2QPK+Kdm/N3qAj5B5nohCLEyYMgVBUO+amUbN/SMljNT9BX4Tp
         I32nh7dPYryADUoTOGqrPOKVCIIB917EjhkbDXhV/YcxUWFoG2sITNFn8FCYZcF7PMW4
         zmmyCuC9brmE4aWUoh7HIo+pbgtQTgu0Af4tTav5M5r6ZadLWBQq0tSZEmBoc+BnrK9a
         cUTIa4k6B85Tq13XcIvfUxKSnmR63aigDK9Xf6McHZ564TD7Vq+LpJOoFGKm3IAdN54Z
         id1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=eumZZKoB;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d5sor41334375qvd.40.2019.04.12.07.16.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 07:16:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=eumZZKoB;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=BNfbrBu7Kf9YbRjnRfGu2WkpXEstm8Do5o3zkCQBOsE=;
        b=eumZZKoBJ/J7a6yZvp+R0ymoOPiMq5XT5S4PwM65P3vrvD20o2zsyrfkkdun5UN7CV
         LPt1ENh3ifW1ZRYnNxRAzmjz4jVP5AAVB79gk9pf74nUEnDKWfg6Bw6Z5qy3xnyHiePU
         LSy7GQXYQttk7Otx7n2V3j9wz1zxN8wQm2Vpr8G6Y1+stOD9mKxvFpRHrV/u8nZbGn9z
         eKPp2H8AxXU8HOUJLLETcz7XjkSZ7dZ47ODe58Mbi1EQMYm5VIfW09Az8ND7F6BsqmGu
         GgMagBo5MQnUhJQcy3g6TBDlKVl6x+aoFhHeWzvhVdcpqKgNqcesBqRG8AQm7vzdTKnv
         kieQ==
X-Google-Smtp-Source: APXvYqyXKlNJWDYZCf5oo200N8SzRVdIL+ocZ9fNq4nkloba4fzT/Zza6kqRyNv2tAtHBLnzjFOUJQ==
X-Received: by 2002:a0c:c165:: with SMTP id i34mr47138291qvh.6.1555078586767;
        Fri, 12 Apr 2019 07:16:26 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id s2sm10321417qkg.67.2019.04.12.07.16.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 07:16:26 -0700 (PDT)
Message-ID: <1555078584.26196.50.camel@lca.pw>
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
From: Qian Cai <cai@lca.pw>
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, 
 ndesaulniers@google.com, kcc@google.com, dvyukov@google.com,
 keescook@chromium.org,  sspatil@android.com, labbott@redhat.com,
 kernel-hardening@lists.openwall.com
Date: Fri, 12 Apr 2019 10:16:24 -0400
In-Reply-To: <20190412124501.132678-1-glider@google.com>
References: <20190412124501.132678-1-glider@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-04-12 at 14:45 +0200, Alexander Potapenko wrote:
> This config option adds the possibility to initialize newly allocated
> pages and heap objects with zeroes. This is needed to prevent possible
> information leaks and make the control-flow bugs that depend on
> uninitialized values more deterministic.
> 
> Initialization is done at allocation time at the places where checks for
> __GFP_ZERO are performed. We don't initialize slab caches with
> constructors or SLAB_TYPESAFE_BY_RCU to preserve their semantics.
> 
> For kernel testing purposes filling allocations with a nonzero pattern
> would be more suitable, but may require platform-specific code. To have
> a simple baseline we've decided to start with zero-initialization.
> 
> No performance optimizations are done at the moment to reduce double
> initialization of memory regions.

Sounds like this has already existed in some degree, i.e.,

CONFIG_PAGE_POISONING_ZERO

