Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD636B02B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:26:24 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 41so49642000iop.2
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 10:26:24 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id y17si1496958iof.156.2017.08.11.10.26.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 10:26:21 -0700 (PDT)
Date: Fri, 11 Aug 2017 12:26:19 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [linux-next][PATCH v2] mm/slub.c: add a naive detection of double
 free or corruption
In-Reply-To: <1502468246-1262-1-git-send-email-alex.popov@linux.com>
Message-ID: <alpine.DEB.2.20.1708111225560.3131@nuc-kabylake>
References: <1502468246-1262-1-git-send-email-alex.popov@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Popov <alex.popov@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Paul E McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Fri, 11 Aug 2017, Alexander Popov wrote:

> Add an assertion similar to "fasttop" check in GNU C Library allocator
> as a part of SLAB_FREELIST_HARDENED feature. An object added to a singly
> linked freelist should not point to itself. That helps to detect some
> double free errors (e.g. CVE-2017-2636) without slub_debug and KASAN.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
