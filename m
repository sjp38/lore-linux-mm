Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB4C6B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 01:52:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j27so18874905wre.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 22:52:12 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id c6si23122757wrc.244.2017.05.24.22.52.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 22:52:10 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id b84so34944070wmh.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 22:52:10 -0700 (PDT)
Date: Thu, 25 May 2017 07:52:07 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
Message-ID: <20170525055207.udcphnshuzl2gkps@gmail.com>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
 <20170524212229.GR141096@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524212229.GR141096@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Douglas Anderson <dianders@chromium.org>, Mark Brown <broonie@kernel.org>, David Miller <davem@davemloft.net>


* Matthias Kaehlcke <mka@chromium.org> wrote:

> El Wed, May 24, 2017 at 02:01:15PM -0700 David Rientjes ha dit:
> 
> > GCC explicitly does not warn for unused static inline functions for
> > -Wunused-function.  The manual states:
> > 
> > 	Warn whenever a static function is declared but not defined or
> > 	a non-inline static function is unused.
> > 
> > Clang does warn for static inline functions that are unused.
> > 
> > It turns out that suppressing the warnings avoids potentially complex
> > #ifdef directives, which also reduces LOC.
> > 
> > Supress the warning for clang.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> 
> As expressed earlier in other threads, I don't think gcc's behavior is
> preferable in this case. The warning on static inline functions (only
> in .c files) allows to detect truly unused code. About 50% of the
> warnings I have looked into so far fall into this category.
> 
> In my opinion it is more valuable to detect dead code than not having
> a few more __maybe_unused attributes (there aren't really that many
> instances, at least with x86 and arm64 defconfig). In most cases it is
> not necessary to use #ifdef, it is an option which is preferred by
> some maintainers. The reduced LOC is arguable, since dectecting dead
> code allows to remove it.

Static inline functions in headers are often not dead code.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
