Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB3DB6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 04:20:19 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m28so104961726pgn.14
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 01:20:19 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id e62si3488491pgc.26.2017.03.28.01.20.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 01:20:19 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id 81so51222777pgh.2
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 01:20:19 -0700 (PDT)
Date: Tue, 28 Mar 2017 01:20:16 -0700
From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] mm: fix section name for .data..ro_after_init
Message-ID: <20170328011951.33dc329c@cakuba.lan>
In-Reply-To: <20170327192213.GA129375@beast>
References: <20170327192213.GA129375@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Eddie Kovsky <ewk@edkovsky.org>, linux-kernel@vger.kernel.org

On Mon, 27 Mar 2017 12:22:13 -0700, Kees Cook wrote:
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

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
