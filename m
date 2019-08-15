Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F4FEC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:38:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48E8C2063F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:38:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CS0VBL1+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48E8C2063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECB146B02F5; Thu, 15 Aug 2019 13:38:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7B856B02F6; Thu, 15 Aug 2019 13:38:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D92706B02F7; Thu, 15 Aug 2019 13:38:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0079.hostedemail.com [216.40.44.79])
	by kanga.kvack.org (Postfix) with ESMTP id B72906B02F5
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:38:37 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 56CBB181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:38:37 +0000 (UTC)
X-FDA: 75825371874.29.room11_685197a6a2321
X-HE-Tag: room11_685197a6a2321
X-Filterd-Recvd-Size: 5804
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:38:36 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id w2so1676417pfi.3
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:38:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=euIwOXnK/svYHHXPSlmp88qDO1N+OcnvV3P5BXMue5g=;
        b=CS0VBL1+zvqK+8DcO7ZE7dAZAaQ0bWWAcL+P2fYvK0b43mojfJGF9QCXVLO7+RDUnA
         Xt8WdeaVCWI4lrvW5qM8iWPEyVG/P6d4KZSU0cdm+rhh2brZLielTHLuieic7j+ZemP2
         1c9mAI8yzVCYQ/rU5M4yrFGMpu0zmiLP4hDx1sqVyAFTNzzoFgvg7XHbF3fl3JsShMZF
         qtqX48eBdG/+bMjZOV3FGk3Wq4oQEJfXuNLnE9nstbVXGJREk0wUfuKECf70hIw8Jbj3
         7QUNRb7MPF1wRGV7IXxLZnV9JdU5/pqjgfx0mgYjL+T7trsepX6NIqZv7fDHWqhi1lnB
         J0Dw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=euIwOXnK/svYHHXPSlmp88qDO1N+OcnvV3P5BXMue5g=;
        b=KU38sF+qcxBFV3kdzcLYTdy2i8FDfeL1aItJUKrYIwPuKwbVao+UlhTCMa/L3iAJX1
         NsHhGiIBtNFjQWi4CQsg3dIJ1dwgvKqIus9q51PXwpkv+8sGv/iT1XCUtmV4e9pM2cMc
         QRlIJ/oV0RcPjHyY9SP09HvVW1KARsOfndoRlG2j0ofvq4qlygHSXV5QUm8F6Ua0myz7
         bP9/uyY/dup0Zy5/Byx4LsYcXOR+3nqaTzgnigU5Wp20DTFfzUNcXEc2Vk6qPLIuI5NA
         YL3AZZ63lg+p9p/Bodq8BhztuZ5DHZEZJV+gZ7oW56bLsMW1gVE9Ceqs3oGgeKhvwMgd
         PRSQ==
X-Gm-Message-State: APjAAAXDg6gymdCP1athXkEsAtGKPjd0Qb+15o1hRw1QoT3LWMi3oZls
	FJLvUuIn/NmLlF1D9xd3CiY=
X-Google-Smtp-Source: APXvYqxYliQ8QXyA6bg2cQ8hluZ/YaCldQ4vOlvxR7/QowwAjhYBKdr+cF6WsHHPG8ro2pXGOHSURw==
X-Received: by 2002:a17:90a:bd0b:: with SMTP id y11mr3104986pjr.141.1565890715816;
        Thu, 15 Aug 2019 10:38:35 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id m20sm3516107pff.79.2019.08.15.10.38.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 10:38:34 -0700 (PDT)
Date: Thu, 15 Aug 2019 10:38:33 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, arnd@arndb.de,
	kirill.shutemov@linux.intel.com, mhocko@suse.com, jgg@ziepe.ca,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2] asm-generic: fix variable 'p4d' set but not used
Message-ID: <20190815173833.GA29763@roeck-us.net>
References: <20190806232917.881-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806232917.881-1-cai@lca.pw>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 07:29:17PM -0400, Qian Cai wrote:
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
> Acked-by: Arnd Bergmann <arnd@arndb.de>

All parisc builds fail with this patch applied.

include/asm-generic/5level-fixup.h:14:18: error:
	unknown type name 'pgd_t'; did you mean 'pid_t'?

Bisect results below.

Guenter

---
# bad: [329120423947e8b36fd2f8b5cf69944405d0aece] Merge tag 'auxdisplay-for-linus-v5.3-rc5' of git://github.com/ojeda/linux
# good: [ee1c7bd33e66376067fd6306b730789ee2ae53e4] Merge tag 'tpmdd-next-20190813' of git://git.infradead.org/users/jjs/linux-tpmdd
git bisect start 'HEAD' 'ee1c7bd33e66'
# bad: [e83b009c5c366b678c7986fa6c1d38fed06c954c] Merge tag 'dma-mapping-5.3-4' of git://git.infradead.org/users/hch/dma-mapping
git bisect bad e83b009c5c366b678c7986fa6c1d38fed06c954c
# bad: [92717d429b38e4f9f934eed7e605cc42858f1839] Revert "Revert "mm, thp: consolidate THP gfp handling into alloc_hugepage_direct_gfpmask""
git bisect bad 92717d429b38e4f9f934eed7e605cc42858f1839
# good: [b997052bc3ac444a0bceab1093aff7ae71ed419e] mm/z3fold.c: fix z3fold_destroy_pool() race condition
git bisect good b997052bc3ac444a0bceab1093aff7ae71ed419e
# good: [951531691c4bcaa59f56a316e018bc2ff1ddf855] mm/usercopy: use memory range to be accessed for wraparound check
git bisect good 951531691c4bcaa59f56a316e018bc2ff1ddf855
# good: [6a2aeab59e97101b4001bac84388fc49a992f87e] seq_file: fix problem when seeking mid-record
git bisect good 6a2aeab59e97101b4001bac84388fc49a992f87e
# bad: [0cfaee2af3a04c0be5f056cebe5f804dedc59a43] include/asm-generic/5level-fixup.h: fix variable 'p4d' set but not used
git bisect bad 0cfaee2af3a04c0be5f056cebe5f804dedc59a43
# first bad commit: [0cfaee2af3a04c0be5f056cebe5f804dedc59a43] include/asm-generic/5level-fixup.h: fix variable 'p4d' set but not used

