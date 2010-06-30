Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6F56B01AF
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 16:07:22 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o5UK7Ie4021528
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 13:07:18 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by hpaq14.eem.corp.google.com with ESMTP id o5UK7Grw000441
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 13:07:17 -0700
Received: by pva18 with SMTP id 18so491050pva.32
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 13:07:16 -0700 (PDT)
Date: Wed, 30 Jun 2010 13:07:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V2] slab: fix caller tracking on !CONFIG_DEBUG_SLAB &&
 CONFIG_TRACING
In-Reply-To: <1277891842-18898-1-git-send-email-dfeng@redhat.com>
Message-ID: <alpine.DEB.2.00.1006301307001.27676@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004090947030.10992@chino.kir.corp.google.com> <1277891842-18898-1-git-send-email-dfeng@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Xiaotian Feng <dfeng@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Vegard Nossum <vegard.nossum@gmail.com>, Dmitry Monakhov <dmonakhov@openvz.org>, Catalin Marinas <catalin.marinas@arm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jun 2010, Xiaotian Feng wrote:

> In slab, all __xxx_track_caller is defined on CONFIG_DEBUG_SLAB || CONFIG_TRACING,
> thus caller tracking function should be worked for CONFIG_TRACING. But if
> CONFIG_DEBUG_SLAB is not set, include/linux/slab.h will define xxx_track_caller to
> __xxx() without consideration of CONFIG_TRACING. This will break the caller tracking
> behaviour then.
> 
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Vegard Nossum <vegard.nossum@gmail.com>
> Cc: Dmitry Monakhov <dmonakhov@openvz.org>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
