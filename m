Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 453BA6B007E
	for <linux-mm@kvack.org>; Sat, 26 Mar 2016 15:06:16 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l71so673850wmg.1
        for <linux-mm@kvack.org>; Sat, 26 Mar 2016 12:06:16 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id gg9si20593047wjb.115.2016.03.26.12.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Mar 2016 12:06:15 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id p65so57252154wmp.1
        for <linux-mm@kvack.org>; Sat, 26 Mar 2016 12:06:15 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 2/2] include/linux: apply __malloc attribute
References: <1458776553-9033-1-git-send-email-linux@rasmusvillemoes.dk>
	<1458776553-9033-2-git-send-email-linux@rasmusvillemoes.dk>
	<20160324153639.bb996d7bf5a585dfb46740b7@linux-foundation.org>
Date: Sat, 26 Mar 2016 20:06:13 +0100
In-Reply-To: <20160324153639.bb996d7bf5a585dfb46740b7@linux-foundation.org>
	(Andrew Morton's message of "Thu, 24 Mar 2016 15:36:39 -0700")
Message-ID: <87mvplukii.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 24 2016, Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 24 Mar 2016 00:42:32 +0100 Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:
>
>> Attach the malloc attribute to a few allocation functions. This helps
>> gcc generate better code by telling it that the return value doesn't
>> alias any existing pointers (which is even more valuable given the
>> pessimizations implied by -fno-strict-aliasing).
>> 
> Shaves 6 bytes off my 1MB i386 defconfig vmlinux.  Winner!

Well, the full bloat-o-meter summary is

add/remove: 0/0 grow/shrink: 72/155 up/down: 1165/-1674 (-509)

which sure still isn't much, but this isn't (just) about saving a few
bytes, but more about allowing gcc to generate better code; sometimes by
not having to reload, but also by enabling it to reorder instructions
(e.g. hoisting a load above a store) - the simple example was chosen
because it was very easy to see the relationship between the source and
the generated code.

Anyway, thanks for picking them up.

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
