Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F73F6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 06:13:58 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r196so10298585itc.4
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 03:13:58 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id 76si3356673ioe.277.2017.12.07.03.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 03:13:57 -0800 (PST)
Date: Thu, 7 Dec 2017 05:13:56 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: Do not hash pointers when debugging slab
In-Reply-To: <1512641861-5113-1-git-send-email-geert+renesas@glider.be>
Message-ID: <alpine.DEB.2.20.1712070512120.7218@nuc-kabylake>
References: <1512641861-5113-1-git-send-email-geert+renesas@glider.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Tobin C . Harding" <me@tobin.cc>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Thu, 7 Dec 2017, Geert Uytterhoeven wrote:

> If CONFIG_DEBUG_SLAB/CONFIG_DEBUG_SLAB_LEAK are enabled, the slab code
> prints extra debug information when e.g. corruption is detected.
> This includes pointers, which are not very useful when hashed.
>
> Fix this by using %px to print unhashed pointers instead.

Acked-by: Christoph Lameter <cl@linux.com>

These SLAB config options are only used for testing so this is ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
