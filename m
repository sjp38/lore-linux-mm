Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8BB4402EE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 06:51:01 -0400 (EDT)
Received: by iow1 with SMTP id 1so78559357iow.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 03:51:01 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id mf6si5593814igb.11.2015.10.02.03.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 03:51:01 -0700 (PDT)
Date: Fri, 2 Oct 2015 05:50:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] slab.h: sprinkle __assume_aligned attributes
In-Reply-To: <1443780775-10304-2-git-send-email-linux@rasmusvillemoes.dk>
Message-ID: <alpine.DEB.2.20.1510020550350.3620@east.gentwo.org>
References: <1443780775-10304-1-git-send-email-linux@rasmusvillemoes.dk> <1443780775-10304-2-git-send-email-linux@rasmusvillemoes.dk>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2 Oct 2015, Rasmus Villemoes wrote:

> The various allocators return aligned memory. Telling the compiler
> that allows it to generate better code in many cases, for example when
> the return value is immediately passed to memset().


Looks good.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
