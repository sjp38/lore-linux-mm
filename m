Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 11BDA828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 11:26:49 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id h5so17756720igh.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 08:26:49 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id k82si51183628iof.133.2016.01.07.08.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 08:26:48 -0800 (PST)
Date: Thu, 7 Jan 2016 10:26:46 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/7] Sanitization of slabs based on grsecurity/PaX
In-Reply-To: <568C8741.4040709@labbott.name>
Message-ID: <alpine.DEB.2.20.1601071020570.28979@east.gentwo.org>
References: <1450755641-7856-1-git-send-email-laura@labbott.name> <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org> <5679ACE9.70701@labbott.name> <CAGXu5jJQKaA1qgLEV9vXEVH4QBC__Vg141BX22ZsZzW6p9yk4Q@mail.gmail.com> <568C8741.4040709@labbott.name>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <laura@labbott.name>
Cc: Kees Cook <keescook@chromium.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, 5 Jan 2016, Laura Abbott wrote:

> It's not the poisoning per se that's incompatible, it's how the poisoning is
> set up. At least for slub, the current poisoning is part of SLUB_DEBUG which
> enables other consistency checks on the allocator. Trying to pull out just
> the poisoning for use when SLUB_DEBUG isn't on would result in roughly what
> would be here anyway. I looked at trying to reuse some of the existing
> poisoning
> and came to the conclusion it was less intrusive to the allocator to keep it
> separate.

SLUB_DEBUG does *not* enable any debugging features. It builds the logic
for debugging into the kernel but does not activate it. CONFIG_SLUB_DEBUG
is set for production kernels. The poisoning is build in by default into
any recent linux kernel out there. You can enable poisoning selectively
(and no other debug feature) by specifying slub_debug=P on the Linux
kernel command line right now.

There is a SLAB_POISON flag for each kmem_cache that can be set to
*only* enable poisoning and nothing else from code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
