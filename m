Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 50D2B6B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:32:21 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id z135so128538175iof.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:32:21 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id ug8si36029251igb.89.2016.02.16.08.32.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 08:32:20 -0800 (PST)
Date: Tue, 16 Feb 2016 10:32:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCHv2 3/4] slub: Convert SLAB_DEBUG_FREE to
 SLAB_CONSISTENCY_CHECKS
In-Reply-To: <1455561864-4217-4-git-send-email-labbott@fedoraproject.org>
Message-ID: <alpine.DEB.2.20.1602161031540.4158@east.gentwo.org>
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org> <1455561864-4217-4-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Mon, 15 Feb 2016, Laura Abbott wrote:

> SLAB_DEBUG_FREE allows expensive consistency checks at free
> to be turned on or off. Expand its use to be able to turn
> off all consistency checks. This gives a nice speed up if
> you only want features such as poisoning or tracing.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
