Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71595C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:30:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C12D22CEB
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:30:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C12D22CEB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA5866B0008; Wed,  7 Aug 2019 03:30:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C544C6B000A; Wed,  7 Aug 2019 03:30:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6ACA6B000C; Wed,  7 Aug 2019 03:30:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A268A6B0008
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:30:44 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d11so78266132qkb.20
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:30:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=QI/I+LIQsvc4f1HJIy3PO112y7pvO/6WR4rKXxmi7/o=;
        b=uev1afo6sKi2AtYc3v4PTdIci0HlKOZfLriXNJi4FZvwxqyjHjH9x0xOTdd2T0b2JJ
         KKsDPGRG1Hro28PWVJ8LZIL0nAXB87RVZ26xLBi3H1eiKjIYADGTw1OJuAjBJq9vsEeV
         9sbT7H4EWLftUC/L8z0t46yQX0JPIycfGytEju2figxys2KD/W0K7E2sY8bT5Zsy7dgb
         y4Tc7SKgom5heRt9wWjDbfVDDKelHx1CdT3Knjbtsa2WXL4wIEnwfUCJC4UfyGq7YPGm
         P8qKLuFq1TbB/BpnXhmFdbSkydZpG6QHrUFp80Qeb7Rp3E8Prj6qbbwL7qM/kmfGVgRS
         rjzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAW/vQA9EJ0sHSMBQH3k88B0kc1/aL4DIou1iCR63yAiq+jJ5ZHz
	Yvc9+it3w3dwYSM+4ToB1w4GUn9i2VuoQX/uboQOcjfwoamw8UvRwUrdPgYLj+i+AVxokvt5K+L
	a/ZCDm7KprAvzgQL2xpnHDgulTimx6hRSYgPExqo/tKbhcHZDk0EvXjF7mStvgVk=
X-Received: by 2002:a05:6214:11ad:: with SMTP id u13mr6596377qvv.31.1565163044475;
        Wed, 07 Aug 2019 00:30:44 -0700 (PDT)
X-Received: by 2002:a05:6214:11ad:: with SMTP id u13mr6596348qvv.31.1565163043955;
        Wed, 07 Aug 2019 00:30:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565163043; cv=none;
        d=google.com; s=arc-20160816;
        b=jqZBUue96C3ZzjhvctENiQOb90v5jcGU1nogeWLiPZ0IDIg1A1QX2L7Lqy293W29F2
         YJZCLtP29dSkC4IJk+4+upJS2cIDgMy67BF4/p1CasdwrKIcv5vLCoF1GDB5/7ZbuQR2
         OhQxCuDxkstY3wo01V6d7XiUun4Sw+MogOnm5O9D4RcPCpX33Ank3OXOLNKcqFW930wH
         5rX74D0bmKbzU6Sn6GeLMDocomA89bRqN5RQq20Rdf2T12wV8RWOxg96OgnU0sTHv/c1
         h8fMKxBoobjmjOfHhl7oa9D1rMrScalftdkfng3u1DDPZ9K5Th2ktwWEdCEYaQyZ/V0a
         s3rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=QI/I+LIQsvc4f1HJIy3PO112y7pvO/6WR4rKXxmi7/o=;
        b=qj8RF72lA/RaiZGn79ceikzsIUcFwk0D9d1kPcsrDwDMiRZNS4JkrRlTTAttx33o28
         e7w6MmCzo/r2acDcUXAfFqhlxH8512/UKNXWNli777VrraH7OnWpUmeTlDYPREerMb8J
         GzBjW4lU5l++sgmG2S+YvCxlK477aFBgZDP0m8AU+YI6J6/1byTGqHkMA2gyYrsr4znB
         0UTkixydFQJfbVduFz2KKFYv7uGP9DfAEWDAuPlClToFpTTXUPNilBccDse410ueOTJ1
         9jqfvmA4jpm72UCG2hsw+yxlE9d9QtfiT38bZlrGYTKaNge2KN3DvpiIiiySPSAYfo5q
         iGwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b22sor2504755qtt.51.2019.08.07.00.30.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 00:30:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqyraFOC5I7agXnUMaIP2SQ2U9Dh7sSaovC+LdeLBhDNbzPybgOWl0piLVtNs5lFOv5CH0Q85Hq+//qGKdglhiY=
X-Received: by 2002:aed:3363:: with SMTP id u90mr6742936qtd.7.1565163043476;
 Wed, 07 Aug 2019 00:30:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190806232917.881-1-cai@lca.pw>
In-Reply-To: <20190806232917.881-1-cai@lca.pw>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 7 Aug 2019 09:30:26 +0200
Message-ID: <CAK8P3a12VZHvX+rTDYenONwjBDbBvi2cT-FaqBcTpHbX8Gz4Bg@mail.gmail.com>
Subject: Re: [PATCH v2] asm-generic: fix variable 'p4d' set but not used
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 7, 2019 at 1:29 AM Qian Cai <cai@lca.pw> wrote:
>
> A compiler throws a warning on an arm64 system since the
> commit 9849a5697d3d ("arch, mm: convert all architectures to use
> 5level-fixup.h"),
>
> mm/kasan/init.c: In function 'kasan_free_p4d':
> mm/kasan/init.c:344:9: warning: variable 'p4d' set but not used
> [-Wunused-but-set-variable]
>  p4d_t *p4d;
>         ^~~
>
> because p4d_none() in "5level-fixup.h" is compiled away while it is a
> static inline function in "pgtable-nopud.h". However, if converted
> p4d_none() to a static inline there, powerpc would be unhappy as it
> reads those in assembler language in
> "arch/powerpc/include/asm/book3s/64/pgtable.h", so it needs to skip
> assembly include for the static inline C function. While at it,
> converted a few similar functions to be consistent with the ones in
> "pgtable-nopud.h".
>
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: Arnd Bergmann <arnd@arndb.de>

