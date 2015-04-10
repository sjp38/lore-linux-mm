Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1E77C6B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 09:02:49 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so25657405wia.0
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 06:02:48 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id fb2si3601768wib.18.2015.04.10.06.02.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Apr 2015 06:02:47 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] arm64: add KASan support
Date: Fri, 10 Apr 2015 15:02:39 +0200
Message-ID: <8790947.ikOtIjWHkt@wuerfel>
In-Reply-To: <5527AA94.5080803@samsung.com>
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com> <3164609.kEhR8riVSV@wuerfel> <5527AA94.5080803@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Friday 10 April 2015 13:48:52 Andrey Ryabinin wrote:
> On 04/09/2015 11:17 PM, Arnd Bergmann wrote:
> > On Tuesday 24 March 2015 17:49:04 Andrey Ryabinin wrote:
> >>  arch/arm64/mm/kasan_init.c           | 211 +++++++++++++++++++++++++++++++++++
> >>
> > 
> > Just one very high-level question: as this code is clearly derived from
> > the x86 version and nontrivial, could we move most of it out of
> > arch/{x86,arm64} into mm/kasan/init.c and have the rest in some header
> > file?
> > 
> 
> I think most of this could be moved out from arch code, but not everything.
> E.g. kasan_init() function is too arch-specific.

Right, makes sense. So presumably, populate_zero_shadow could become a global
function by another name, and possibly also handle registering the die
handler, so you can call it from an architecture specific kasan_init() 
function, right?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
