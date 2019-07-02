Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BB0DC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 12:41:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E474C205F4
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 12:41:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AnQR4gKj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E474C205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 843376B0003; Tue,  2 Jul 2019 08:41:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F43F8E0003; Tue,  2 Jul 2019 08:41:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BC598E0001; Tue,  2 Jul 2019 08:41:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7F16B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 08:41:08 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id t198so6473708oih.20
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 05:41:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Q3d2uVGgar8aJnCM9NISkpoH5GB88E6BUU5dyE7CfSc=;
        b=T4fE9qXbu2bygiBoXjhJweNd63kmozxWGbiKuWpc16xGqzCKZ42X0VXweSqPT5xrLR
         4z7kUpex8SlEkm6nrsQ9nkiHCYhJlsCAg7VolTipZXD8Z3eR4tI0IBZYNmN0bj7ilSCU
         AB6/B1VmwCUb0bbeMOCKxNXKOWyZexV50OkFTaCDimghLD7V0B+WnI03FZNYMqzkDz5I
         KmvwyTYKFdll5rJtH0+8tKPvIPiMDxFMtqOInfaKEteXGGdNfW3nxPVKy9/LEuCOBBPR
         nHvRQPVCJN57XmYeCJwf7sA5H/jdcDQU8RjZn43mVor51J/le7/CuozP+nrISi6B/NCB
         Q+Mw==
X-Gm-Message-State: APjAAAWoyoozshFsDHEMqMkdqd+qPjKDPb10EB3VRrjdBG1pZpNQZqtx
	hY4KeLWR+at/RMMns9c4BlO/pHMJj7MWCoV5S/t7XZ1vjopXPbWGKSbYcewP7oxuuEw9K1UXWZR
	tkw3/93IIRmY3zvaRRs2Kccjjucmcw9CSSjB2xgr1BPkjL1Xb1cvSvK68Yfg7TZnxWw==
X-Received: by 2002:a9d:1718:: with SMTP id i24mr22796171ota.269.1562071267893;
        Tue, 02 Jul 2019 05:41:07 -0700 (PDT)
X-Received: by 2002:a9d:1718:: with SMTP id i24mr22796139ota.269.1562071267140;
        Tue, 02 Jul 2019 05:41:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562071267; cv=none;
        d=google.com; s=arc-20160816;
        b=qFkdyiDGMOotLQrTOnup2R/gUvhU5iGHc79RWoOx+G0TygLbY0OdXY4/KP1v21luxF
         fVCeVaNfaqFyLC88n+QAnIsB2Au4qcw5iCf6SOr2Ea02gwhQInb8Lvw0l/QwlYGO1p+S
         Ki2dE2a8ldNQjIVqGdqjVNEviqYEXot/uYaU7xqCYFh6imfCASzsC1tUSEZILkdcbZ26
         uCNzpm49rD+UXvc0UXBEGEBGqeJZtYmnGLgsEZ0GR8/Scf95DxpXAtn6lRGPRlcJ5RlN
         guNIFMAFZGvaIErlRsypicrNRKeD90PlJfEOF6iMN+Khk6Qg8nV5yq2Jj4Kjmk7454fi
         48EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Q3d2uVGgar8aJnCM9NISkpoH5GB88E6BUU5dyE7CfSc=;
        b=Y5QKlEGLQ8NdxJqbfcxZGlM9StqZIbzYG+3WsBNhO2DpUGIlxhTwO6wx2nwqIlz8h6
         ZeZ+GQ/0Uc2psUdQTXZ1UOCHvK9cGTcl7+jcL4j4w6chCl9A14rtllEI1xyn5ROuG/HI
         o/bRTTIsK9j0J+cqFXbUP8kYQMBTHtE1lvAjjmTpRtZ68UdjYvSf9WiCs080Vw/9rHZC
         kt54IXm2+cIWqOjl2Wm97RPd5Ak7Vs+IzxpUhaoT/PERr0qGez7QY1buwyT8h2Nzcu/i
         kxXQXVm6vqnr1MUlx3UQHSpsm0pJ23xpFj1TGMslDs1SuhQJYw3VO7TUFfq8ifspx7Dc
         cDcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AnQR4gKj;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor7361097oto.165.2019.07.02.05.41.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 05:41:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AnQR4gKj;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Q3d2uVGgar8aJnCM9NISkpoH5GB88E6BUU5dyE7CfSc=;
        b=AnQR4gKjvlfra9r4U22xdnqBWCLqaeDfbfO3DFnC7u3cR4dvI/9H/GaN7PtzVcMIb0
         D4gsPvhEdywks5rm09wnaqvmAgSYdbp4knPKvNT7UNFelLG4XtpqJpA4Nkc7545MoH73
         TUEbHvvEWX+Ce86nVv7wiz8LfiwNJNsHeypGVwV2n+GjrRBxZyMHsbxDWhhd7EdYb85p
         dB0omSFR735q1Oi76Wgca+SCbg/pdl5+ScxAkTT2s1miusemD1OHaz4+OmqIQ2l7Z0N1
         cHAlCt8ZsenLAGNMTqDMAi+ukLtCB/if8F2dKm2st0W+wbjtjtgMCNi9CR3uNZFRoUku
         OAbA==
X-Google-Smtp-Source: APXvYqztUsddo/7fSNKF3gmOLDRP3q+d0mchRHkkjLx3+Zn8quzFaqWzYCR8YsRlIq4fsNiyKsybv6H9499E8yiRee8=
X-Received: by 2002:a9d:67cf:: with SMTP id c15mr22927046otn.326.1562071266955;
 Tue, 02 Jul 2019 05:41:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190630075650.8516-1-lpf.vector@gmail.com> <20190630075650.8516-4-lpf.vector@gmail.com>
 <20190702122321.GC1729@bombadil.infradead.org>
In-Reply-To: <20190702122321.GC1729@bombadil.infradead.org>
From: oddtux <lpf.vector@gmail.com>
Date: Tue, 2 Jul 2019 20:40:55 +0800
Message-ID: <CAD7_sbFQgkyTDfePp4FROdJc+UB3zqF8DiTosmi-JPUJsgBfWw@mail.gmail.com>
Subject: Re: [PATCH 3/5] mm/vmalloc.c: Rename function __find_vmap_area() for readability
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, peterz@infradead.org, 
	Uladzislau Rezki <urezki@gmail.com>, rpenyaev@suse.de, mhocko@suse.com, guro@fb.com, 
	aryabinin@virtuozzo.com, rppt@linux.ibm.com, mingo@kernel.org, 
	rick.p.edgecombe@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 2, 2019 at 8:23 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Sun, Jun 30, 2019 at 03:56:48PM +0800, Pengfei Li wrote:
> > Rename function __find_vmap_area to __search_va_from_busy_tree to
> > indicate that it is searching in the *BUSY* tree.
>
> Wrong preposition; you search _in_ a tree, not _from_ a tree.

Thanks for your review, I will correct it in the next version.

