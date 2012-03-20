Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 6775E6B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 10:22:33 -0400 (EDT)
Date: Tue, 20 Mar 2012 09:20:58 -0500
From: Peter Seebach <peter.seebach@windriver.com>
Subject: Re: [RFC PATCH 1/6] kenrel.h: add ALIGN_OF_LAST_BIT()
Message-ID: <20120320092058.1b3271a4@wrlaptop>
In-Reply-To: <op.wbgvn00x3l0zgt@mpn-glaptop>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
	<1332238884-6237-2-git-send-email-laijs@cn.fujitsu.com>
	<op.wbgvn00x3l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 20 Mar 2012 12:32:14 +0100
Michal Nazarewicz <mina86@mina86.com> wrote:

> >+#define ALIGN_OF_LAST_BIT(x)	((((x)^((x) - 1))>>1) + 1)  
> 
> Wouldn't ALIGNMENT() be less confusing? After all, that's what this
> macro is calculating, right? Alignment of given address.

Why not just LAST_BIT(x)?  It's not particularly specific to pointer
alignment, even though that's the context in which it apparently came
up.  So far as I can tell, this isn't even meaningfully defined on
pointer types as such; you'd have to convert.  So the implications for
alignment seem a convenient side-effect, really.

It might be instructive to see some example proposed uses; the question
of why I'd care what alignment something had, rather than whether it
was aligned for a given type, is one that will doubtless keep me awake
nights.

I guess this feels like it answers a question that is usually the wrong
question.  Imagine if you will a couple-page block of memory, full of
unsigned shorts.  Iterate through the array, calculating
ALIGN_OF_LAST_BIT(&a[i]).  Do we really *care* that it's PAGE_SIZE for
some i, and 2 (I assume) for other i, and PAGE_SIZE*2 for either i==0 or
i==PAGE_SIZE?  (Apologies if this is a silly question; maybe this is
such a commonly-needed feature that it's obvious.)

-s
-- 
Listen, get this.  Nobody with a good compiler needs to be justified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
