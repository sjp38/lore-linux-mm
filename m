Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7116B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 13:43:15 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id t20so4350239vkb.17
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 10:43:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor2216853uat.303.2017.12.07.10.43.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 10:43:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712070512120.7218@nuc-kabylake>
References: <1512641861-5113-1-git-send-email-geert+renesas@glider.be> <alpine.DEB.2.20.1712070512120.7218@nuc-kabylake>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Dec 2017 10:43:09 -0800
Message-ID: <CAGXu5j+9qWBM3G1ZtBXPi35UGkcfXnSbgZCBjXJM35X9+hS4ug@mail.gmail.com>
Subject: Re: [PATCH] mm/slab: Do not hash pointers when debugging slab
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Geert Uytterhoeven <geert+renesas@glider.be>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Tobin C . Harding" <me@tobin.cc>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Dec 7, 2017 at 3:13 AM, Christopher Lameter <cl@linux.com> wrote:
> On Thu, 7 Dec 2017, Geert Uytterhoeven wrote:
>
>> If CONFIG_DEBUG_SLAB/CONFIG_DEBUG_SLAB_LEAK are enabled, the slab code
>> prints extra debug information when e.g. corruption is detected.
>> This includes pointers, which are not very useful when hashed.
>>
>> Fix this by using %px to print unhashed pointers instead.
>
> Acked-by: Christoph Lameter <cl@linux.com>
>
> These SLAB config options are only used for testing so this is ok.

Most systems use SLUB so I can't say how common CONFIG_DEBUG_SLAB is.
(Though, FWIW with SLUB, CONFIG_SLUB_DEBUG is very common.)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
