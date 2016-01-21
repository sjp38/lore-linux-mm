Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 42A106B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 10:39:22 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id 77so57772208ioc.2
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 07:39:22 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id u31si5421899ioi.133.2016.01.21.07.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 07:39:21 -0800 (PST)
Date: Thu, 21 Jan 2016 09:39:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/7] Sanitization of slabs based on grsecurity/PaX
In-Reply-To: <56A051EA.8080003@labbott.name>
Message-ID: <alpine.DEB.2.20.1601210937540.7063@east.gentwo.org>
References: <1450755641-7856-1-git-send-email-laura@labbott.name> <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org> <5679ACE9.70701@labbott.name> <CAGXu5jJQKaA1qgLEV9vXEVH4QBC__Vg141BX22ZsZzW6p9yk4Q@mail.gmail.com> <568C8741.4040709@labbott.name>
 <alpine.DEB.2.20.1601071020570.28979@east.gentwo.org> <568F0F75.4090101@labbott.name> <alpine.DEB.2.20.1601080806020.4128@east.gentwo.org> <56971AE1.1020706@labbott.name> <56A051EA.8080003@labbott.name>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <laura@labbott.name>
Cc: Kees Cook <keescook@chromium.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

n Wed, 20 Jan 2016, Laura Abbott wrote:

> The SLAB_DEBUG flags force everything to skip the CPU caches which is
> causing the slow down. I experimented with allowing the debugging to
> happen with CPU caches but I'm not convinced it's possible to do the
> checking on the fast path in a consistent manner without adding
> locking. Is it worth refactoring the debugging to be able to be used
> on cpu caches or should I take the approach here of having the clear
> be separate from free_debug_processing?

At least posioning would benefit from such work. I think both
sanitization and posoning should be done by the same logic. Remove
poisoning if necessary.

Note though that this security stuff should not have a significant impact
on the general case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
