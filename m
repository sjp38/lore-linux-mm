Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 135EA82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 15:01:36 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id to18so64709971igc.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:01:36 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id h10si8292073igq.87.2015.12.22.12.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 12:01:35 -0800 (PST)
Date: Tue, 22 Dec 2015 14:01:34 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
In-Reply-To: <CA+rthh_agt=YmHGUvBo_+-psOg06DYySqyvkvNNuPmrCKiBC2w@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1512221400100.15237@east.gentwo.org>
References: <1450755641-7856-1-git-send-email-laura@labbott.name> <1450755641-7856-7-git-send-email-laura@labbott.name> <CA+rthh-X2jvGpptE72CCbOx2MdkukJSCu621+9ymMJ_pCQ9t+w@mail.gmail.com> <56798D8F.9090402@labbott.name>
 <CA+rthh_agt=YmHGUvBo_+-psOg06DYySqyvkvNNuPmrCKiBC2w@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathias Krause <minipli@googlemail.com>
Cc: Laura Abbott <laura@labbott.name>, kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kees Cook <keescook@chromium.org>

On Tue, 22 Dec 2015, Mathias Krause wrote:

> How many systems, do you think, are running with enabled DEBUG_SLAB /
> SLUB_DEBUG in production? Not so many, I'd guess. And the ones running
> into issues probably just disable DEBUG_SLAB / SLUB_DEBUG.

All systems run with SLUB_DEBUG in production. SLUB_DEBUG causes the code
for debugging to be compiled in. Then it can be enabled later with a
command line parameter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
