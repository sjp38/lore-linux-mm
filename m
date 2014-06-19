Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 791496B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 17:06:54 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so2200706pdb.39
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:06:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ev3si7087411pbb.114.2014.06.19.14.06.53
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 14:06:53 -0700 (PDT)
Date: Thu, 19 Jun 2014 14:06:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: slub: SLUB_DEBUG=n: use the same alloc/free hooks
 as for SLUB_DEBUG=y
Message-Id: <20140619140651.c3c49cf70a7f349db595239e@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1406191555110.4002@gentwo.org>
References: <1403193138-7677-1-git-send-email-a.ryabinin@samsung.com>
	<alpine.DEB.2.11.1406191555110.4002@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, ryabinin.a.a@gmail.com, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>

On Thu, 19 Jun 2014 15:56:56 -0500 (CDT) Christoph Lameter <cl@gentwo.org> wrote:

> On Thu, 19 Jun 2014, Andrey Ryabinin wrote:
> 
> > I see no reason why calls to other debugging subsystems (LOCKDEP,
> > DEBUG_ATOMIC_SLEEP, KMEMCHECK and FAILSLAB) are hidden under SLUB_DEBUG.
> > All this features should work regardless of SLUB_DEBUG config, as all of
> > them already have own Kconfig options.
> 
> The reason for hiding this under SLUB_DEBUG was to have some way to
> guarantee that no instrumentations is added if one does not want it.
> 
> SLUB_DEBUG is on by default and builds in a general
> debugging framework that can be enabled at runtime in
> production kernels.
> 
> If someone disabled SLUB_DEBUG then that has been done with the intend to
> get a minimal configuration.
> 

(Is that a nack?)

The intent seems to have been implemented strangely.  Perhaps it would
be clearer and more conventional to express all this using Kconfig
logic.

Anyway, if we plan to leave the code as-is then can we please get a
comment in there so the next person is not similarly confused?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
