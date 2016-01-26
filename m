Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1542A6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:57:32 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id z14so60381861igp.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 06:57:32 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id x4si119925igg.49.2016.01.26.06.57.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 06:57:31 -0800 (PST)
Date: Tue, 26 Jan 2016 08:57:29 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/3] Speed up SLUB poisoning + disable checks
In-Reply-To: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
Message-ID: <alpine.DEB.2.20.1601260856160.27338@east.gentwo.org>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Mon, 25 Jan 2016, Laura Abbott wrote:

> slub_debug=-:  7.437
> slub_debug=-:   7.932

So thats an almost 10% performance regression if the feature is not used.
The reason that posoning is on the slow path is because it is impacting
performance. Focus on optimizing the debug path without impacting the fast
path please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
