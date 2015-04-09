Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id A00636B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 16:18:08 -0400 (EDT)
Received: by wiun10 with SMTP id n10so2161399wiu.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 13:18:08 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id da9si17909429wib.71.2015.04.09.13.18.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 13:18:07 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] arm64: add KASan support
Date: Thu, 09 Apr 2015 22:17:28 +0200
Message-ID: <3164609.kEhR8riVSV@wuerfel>
In-Reply-To: <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com>
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com> <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tuesday 24 March 2015 17:49:04 Andrey Ryabinin wrote:
>  arch/arm64/mm/kasan_init.c           | 211 +++++++++++++++++++++++++++++++++++
> 

Just one very high-level question: as this code is clearly derived from
the x86 version and nontrivial, could we move most of it out of
arch/{x86,arm64} into mm/kasan/init.c and have the rest in some header
file?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
