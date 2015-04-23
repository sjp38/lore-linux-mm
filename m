Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id DF2676B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 09:58:18 -0400 (EDT)
Received: by qku63 with SMTP id 63so10711051qku.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:58:18 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id i40si8156625qkh.103.2015.04.23.06.58.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 06:58:18 -0700 (PDT)
Date: Thu, 23 Apr 2015 08:58:17 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] linux/slab.h: fix three off-by-one typos in comment
In-Reply-To: <1429783484-29690-1-git-send-email-linux@rasmusvillemoes.dk>
Message-ID: <alpine.DEB.2.11.1504230857440.32203@gentwo.org>
References: <1429783484-29690-1-git-send-email-linux@rasmusvillemoes.dk>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 23 Apr 2015, Rasmus Villemoes wrote:

> The first is a keyboard-off-by-one, the other two the ordinary mathy
> kind.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
