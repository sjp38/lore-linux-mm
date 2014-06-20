Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 88A346B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 10:29:27 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id x12so3248159qac.35
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 07:29:27 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id i14si10975331qay.114.2014.06.20.07.29.26
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 07:29:26 -0700 (PDT)
Date: Fri, 20 Jun 2014 09:29:23 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] mm: slub: SLUB_DEBUG=n: use the same alloc/free hooks
 as for SLUB_DEBUG=y
In-Reply-To: <20140619140651.c3c49cf70a7f349db595239e@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1406200925360.10271@gentwo.org>
References: <1403193138-7677-1-git-send-email-a.ryabinin@samsung.com> <alpine.DEB.2.11.1406191555110.4002@gentwo.org> <20140619140651.c3c49cf70a7f349db595239e@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, ryabinin.a.a@gmail.com, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>

On Thu, 19 Jun 2014, Andrew Morton wrote:

> (Is that a nack?)

Not sure.

> The intent seems to have been implemented strangely.  Perhaps it would
> be clearer and more conventional to express all this using Kconfig
> logic.

Well it really does not work right since SLUB_DEBUG=y is the default
config and this behavior would be a bit surprising.

> Anyway, if we plan to leave the code as-is then can we please get a
> comment in there so the next person is not similarly confused?

Ok. Lets apply the patch.

Gosh. I think we need some way to figure out if code is being added to the
critical paths. I had no idea about that latest issue where might_sleep
suddenly became a call to cond_resched() until I saw the bug report.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
