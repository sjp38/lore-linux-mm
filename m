Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE366B03B1
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 01:35:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m66so101164733pga.15
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 22:35:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d185si2997236pgc.362.2017.03.27.22.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 22:35:47 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2S5Sa1F094296
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 01:35:46 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29fhmbryh2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 01:35:46 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 28 Mar 2017 06:35:44 +0100
Date: Tue, 28 Mar 2017 07:35:39 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm: fix section name for .data..ro_after_init
References: <20170327192213.GA129375@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170327192213.GA129375@beast>
Message-Id: <20170328053539.GA4902@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Jakub Kicinski <jakub.kicinski@netronome.com>, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Eddie Kovsky <ewk@edkovsky.org>, linux-kernel@vger.kernel.org

On Mon, Mar 27, 2017 at 12:22:13PM -0700, Kees Cook wrote:
> A section name for .data..ro_after_init was added by both:
> 
>     commit d07a980c1b8d ("s390: add proper __ro_after_init support")
> 
> and
> 
>     commit d7c19b066dcf ("mm: kmemleak: scan .data.ro_after_init")
> 
> The latter adds incorrect wrapping around the existing s390 section,
> and came later. I'd prefer the s390 naming, so this moves the
> s390-specific name up to the asm-generic/sections.h and renames the
> section as used by kmemleak (and in the future, kernel/extable.c).
> 
> Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Eddie Kovsky <ewk@edkovsky.org>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  arch/s390/include/asm/sections.h  | 1 -
>  arch/s390/kernel/vmlinux.lds.S    | 2 --
>  include/asm-generic/sections.h    | 6 +++---
>  include/asm-generic/vmlinux.lds.h | 4 ++--
>  mm/kmemleak.c                     | 2 +-
>  5 files changed, 6 insertions(+), 9 deletions(-)

For the s390 bits:
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
