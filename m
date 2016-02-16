Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 604226B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:33:44 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id hb3so77002093igb.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:33:44 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id qt6si14462igb.0.2016.02.16.08.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 08:33:43 -0800 (PST)
Date: Tue, 16 Feb 2016 10:33:42 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCHv2 4/4] slub: Relax CMPXCHG consistency restrictions
In-Reply-To: <1455561864-4217-5-git-send-email-labbott@fedoraproject.org>
Message-ID: <alpine.DEB.2.20.1602161033260.4158@east.gentwo.org>
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org> <1455561864-4217-5-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Mon, 15 Feb 2016, Laura Abbott wrote:

> When debug options are enabled, cmpxchg on the page is disabled. This is
> because the page must be locked to ensure there are no false positives
> when performing consistency checks. Some debug options such as poisoning
> and red zoning only act on the object itself. There is no need to
> protect other CPUs from modification on only the object. Allow cmpxchg
> to happen with poisoning and red zoning are set on a slab.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
