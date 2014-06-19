Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id F03076B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 10:37:17 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id v10so1981288qac.41
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 07:37:17 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id n89si6587084qge.73.2014.06.19.07.37.17
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 07:37:17 -0700 (PDT)
Date: Thu, 19 Jun 2014 09:37:14 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] mm: slab.h: wrap the whole file with guarding macro
In-Reply-To: <alpine.DEB.2.02.1406190213070.13670@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1406190936270.2785@gentwo.org>
References: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com> <alpine.DEB.2.02.1406181321010.10339@chino.kir.corp.google.com> <53A29158.2050809@samsung.com> <alpine.DEB.2.02.1406190213070.13670@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Jun 2014, David Rientjes wrote:

> On Thu, 19 Jun 2014, Andrey Ryabinin wrote:
>
> > I had to do some modifications in this file for some reasons, and for me it was hard to not
> > notice lack of endif in the end.
> >
>
> Ok, cool, I don't think there's any need for a stable backport in that
> case.  Thanks for fixing it!

mm/slab.h is only included by mm/sl?b*.c so there is actually no effect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
