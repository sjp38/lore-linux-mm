Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 519C2C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:08:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE35220693
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:08:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="O4nOZ1ak"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE35220693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99D646B0007; Thu, 18 Apr 2019 18:08:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 924FB6B0008; Thu, 18 Apr 2019 18:08:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C82C6B000A; Thu, 18 Apr 2019 18:08:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57AF26B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:08:42 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id c2so3167259ioh.11
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:08:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=b6tmuUkZe+DtpkR/zgdgO+AIem8MXOPJbKQ2qk7t24Q=;
        b=R3shD0dhSt/SUfxdgONGwMX2dibzRTS/BExg/JE95OcdnqEj1p+rbIwkbQM+e8jKZH
         MGAyylxEd86ApPQKi32RWWFgigDAPkLtqr0Pq2jtroCMChnOaapnNBOfCQPBgUXYYhz6
         aqFPIxC7Q5sfOYk9CCBcqOSOmSiyNzsmwwpBEdXhINBYCKt/atOea8GRKQbyfCc61YB2
         YZ7MQS+NfuPV2ZtfZK3CuJsUXBoYOqlcWEX4/t5no2LNOjBVHxDiFRlDj1G+JzZVZoWz
         PBnfmJOKzcXANp92Eq879+F+tTV62uqTwzoNfj9i7+rjdV4jq1gVM84kNnS0rHAHw6Ks
         YDew==
X-Gm-Message-State: APjAAAVmMSl4i4MdDgb7EiiEchzVvhCIU164IdqQOjUv/uK+bB3zej7k
	eUJu+SLL0Lp3WjbzYK31NilUpiEt0Wtcjp22ZIlvTeYbnUSrkc6NeqWaNhwka12qC3vglRW8l+S
	7+w090aAALSL98YfSF/ij70hrY+jc6bIKP1C4XgWzKO9PSSXn59hrKdIFES6UBYnRzw==
X-Received: by 2002:a24:549:: with SMTP id 70mr292675itl.108.1555625322065;
        Thu, 18 Apr 2019 15:08:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEJLP2ZxRa78tMkL2PJ3r3xO4ed3esUpIRUk7w0YnevYLmPEBp7KuN6Xv3Goh5RjZc+FEa
X-Received: by 2002:a24:549:: with SMTP id 70mr292616itl.108.1555625321371;
        Thu, 18 Apr 2019 15:08:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555625321; cv=none;
        d=google.com; s=arc-20160816;
        b=UvfMDS7gui2X6aLjEU29ucqSxBc+iiOnfhRiA94b1/ZBDRHtdPw1nOmzN0LMw2M1hN
         1/66U/wQvgTsE+Hj0QNFQpIPxiICN4FsjBhHuKakvzrUXZCxmm9UtPJ8xk+3X+aw8j5c
         vzZtO2YNTHTVY5ePavolW4J8NhdSDyWGIozV12APSoxJev91S81e0jcrG2ssZeoJ6lYj
         mGPAMyePUx4my1nwDckeL5gSRXjHP0lZyt62W/zgJY+hh0XdUT0A4ysmc92KQ7rtKI+N
         QvB5RP6tmFY22p49zk7hpUFGuw1+nf1zwWLgyEKF4gxLK2PaIeo6vlD1BnEfZINzkxJa
         tXKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=b6tmuUkZe+DtpkR/zgdgO+AIem8MXOPJbKQ2qk7t24Q=;
        b=s/ElIIK97d4OVVJEviY9JPKDrp42CPq85FKzxd/UehDXn1KywvCN2HDFDD2iDxrTcD
         rqwhmLnEVB/c/8efcYsQkqX4Wohka51Q23ygb87Hsu/QrMBcP/wTvhofxh/VwM/VxEYF
         YIcFe0na/Oti8IWyjXwvjythI+thudrxyhwU5YdYoCaaX4dvxQWfqMjH7LrCirLS513j
         sjkXXWZGubkvKdGT62DiJ9iDdmaqiOymh0g33BheLpqphkD5iTAdkqMgmrdbL6kE3hc6
         d3VFauA8vRKV2UNRbSOJseI5vyhTJVMooVaDxWtR8Ay8QRdMCnERdi+vqhlGP5wloDMQ
         Rxxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=O4nOZ1ak;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p7si1903217iom.85.2019.04.18.15.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Apr 2019 15:08:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=O4nOZ1ak;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=b6tmuUkZe+DtpkR/zgdgO+AIem8MXOPJbKQ2qk7t24Q=; b=O4nOZ1akpkIJOV8mffrDymL9iE
	CDfASismBTa7bxM6DgR7c5zCSI2qfxWYoMg9qA//sfz9KJX9JmaE+vKRlk/7Wd2q081Eg8meJ3dE9
	00lEyFLRiEjXksPny/LhMKUVKtmzlnCsK1Iin1aOJ8JHQA13P4jWINk0Vx/R+4wFLnz9fKC6mvdIx
	vIvJBY6k+pvYrgQ5hz+MOv4k9wRmtLiKC1E+b5m8Dy+LjlEX034bJBI/WoelDIpTrvZ+4GX0tBGoT
	bN5QgQbvDxoPbF5ejvON9jQoWaukWILfXD7/mcOoGPYvgI/IQTIFGId/C0i80WAnQqw+3NsuzXg2Z
	cRqv7rWg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hHFCw-0007Oc-LL; Thu, 18 Apr 2019 22:08:38 +0000
Subject: Re: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot
 option
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org,
 cl@linux.com, dvyukov@google.com, keescook@chromium.org, labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org,
 kernel-hardening@lists.openwall.com
References: <20190418154208.131118-1-glider@google.com>
 <20190418154208.131118-2-glider@google.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <ff1f408b-cf37-7df0-2393-7bc2078f6c63@infradead.org>
Date: Thu, 18 Apr 2019 15:08:37 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418154208.131118-2-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 8:42 AM, Alexander Potapenko wrote:
> This option adds the possibility to initialize newly allocated pages and
> heap objects with zeroes. This is needed to prevent possible information
> leaks and make the control-flow bugs that depend on uninitialized values
> more deterministic.
> 
> Initialization is done at allocation time at the places where checks for
> __GFP_ZERO are performed. We don't initialize slab caches with
> constructors to preserve their semantics. To reduce runtime costs of
> checking cachep->ctor we replace a call to memset with a call to
> cachep->poison_fn, which is only executed if the memory block needs to
> be initialized.
> 
> For kernel testing purposes filling allocations with a nonzero pattern
> would be more suitable, but may require platform-specific code. To have
> a simple baseline we've decided to start with zero-initialization.
> 
> No performance optimizations are done at the moment to reduce double
> initialization of memory regions.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: James Morris <jmorris@namei.org>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com
> ---
>  drivers/infiniband/core/uverbs_ioctl.c |  2 +-
>  include/linux/mm.h                     |  8 ++++++++
>  include/linux/slab_def.h               |  1 +
>  include/linux/slub_def.h               |  1 +
>  kernel/kexec_core.c                    |  2 +-
>  mm/dmapool.c                           |  2 +-
>  mm/page_alloc.c                        | 18 +++++++++++++++++-
>  mm/slab.c                              | 12 ++++++------
>  mm/slab.h                              |  1 +
>  mm/slab_common.c                       | 15 +++++++++++++++
>  mm/slob.c                              |  2 +-
>  mm/slub.c                              |  8 ++++----
>  net/core/sock.c                        |  2 +-
>  13 files changed, 58 insertions(+), 16 deletions(-)
> 

Hi,
Please document init_allocations=N in Documentation/admin-guide/kernel-parameters.txt.

thanks.
-- 
~Randy

