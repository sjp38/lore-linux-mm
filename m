Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id C061C6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:00:24 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id t15so60559952igr.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:00:24 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id b28si5504399ioj.51.2016.01.26.07.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 07:00:21 -0800 (PST)
Date: Tue, 26 Jan 2016 09:00:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] slub: Add option to skip consistency checks
In-Reply-To: <1453770913-32287-4-git-send-email-labbott@fedoraproject.org>
Message-ID: <alpine.DEB.2.20.1601260858590.27338@east.gentwo.org>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org> <1453770913-32287-4-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Mon, 25 Jan 2016, Laura Abbott wrote:

> SLUB debugging by default does checks to ensure consistency.
> These checks, while useful, are expensive for allocation speed.
> Features such as poisoning and tracing can stand alone without
> any checks. Add a slab flag to skip these checks.

I would suggest to rename the SLAB_DEBUG_FREE to SLAB_CONSISTENCY_CHECKS
instead. I think the flag is already used that way in a couple of places.

Flags generally enable stuff. Disabling what is enabled by others is
something that we want to avoid for simplicities sake.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
