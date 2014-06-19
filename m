Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 11ADC6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:57:00 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id hw13so2390566qab.20
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:56:59 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id o10si8084303qab.80.2014.06.19.13.56.59
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 13:56:59 -0700 (PDT)
Date: Thu, 19 Jun 2014 15:56:56 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] mm: slub: SLUB_DEBUG=n: use the same alloc/free hooks
 as for SLUB_DEBUG=y
In-Reply-To: <1403193138-7677-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1406191555110.4002@gentwo.org>
References: <1403193138-7677-1-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ryabinin.a.a@gmail.com, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>

On Thu, 19 Jun 2014, Andrey Ryabinin wrote:

> I see no reason why calls to other debugging subsystems (LOCKDEP,
> DEBUG_ATOMIC_SLEEP, KMEMCHECK and FAILSLAB) are hidden under SLUB_DEBUG.
> All this features should work regardless of SLUB_DEBUG config, as all of
> them already have own Kconfig options.

The reason for hiding this under SLUB_DEBUG was to have some way to
guarantee that no instrumentations is added if one does not want it.

SLUB_DEBUG is on by default and builds in a general
debugging framework that can be enabled at runtime in
production kernels.

If someone disabled SLUB_DEBUG then that has been done with the intend to
get a minimal configuration.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
