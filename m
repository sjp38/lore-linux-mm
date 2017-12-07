Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2B0A6B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 15:15:29 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o66so274020ita.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 12:15:29 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id c70si4588357ioa.57.2017.12.07.12.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 12:15:29 -0800 (PST)
Date: Thu, 7 Dec 2017 14:15:27 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: Do not hash pointers when debugging slab
In-Reply-To: <CAGXu5j+9qWBM3G1ZtBXPi35UGkcfXnSbgZCBjXJM35X9+hS4ug@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1712071413470.29779@nuc-kabylake>
References: <1512641861-5113-1-git-send-email-geert+renesas@glider.be> <alpine.DEB.2.20.1712070512120.7218@nuc-kabylake> <CAGXu5j+9qWBM3G1ZtBXPi35UGkcfXnSbgZCBjXJM35X9+hS4ug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Geert Uytterhoeven <geert+renesas@glider.be>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Tobin C . Harding" <me@tobin.cc>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, 7 Dec 2017, Kees Cook wrote:

> > These SLAB config options are only used for testing so this is ok.
>
> Most systems use SLUB so I can't say how common CONFIG_DEBUG_SLAB is.
> (Though, FWIW with SLUB, CONFIG_SLUB_DEBUG is very common.)

CONFIG_SLUB_DEBUG is on by default because it compiles into the kernel the
runtime configurable debugging framework. It does not activate any
debugging.

CONFIG_SLUB_DEBUG_ON is the equivalent to CONFIG_SLAB_DEBUG. The kernel
will boot with debugging on without any extra kernel options with these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
