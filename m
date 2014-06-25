Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9386B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 13:30:06 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id hw13so1786021qab.6
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 10:30:06 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id x9si5609558qab.82.2014.06.25.10.30.05
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 10:30:05 -0700 (PDT)
Date: Wed, 25 Jun 2014 12:30:02 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: mm: slub: invalid memory access in setup_object
In-Reply-To: <53AAFDF7.2010607@oracle.com>
Message-ID: <alpine.DEB.2.11.1406251228130.29216@gentwo.org>
References: <53AAFDF7.2010607@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Wed, 25 Jun 2014, Sasha Levin wrote:

> [  791.669480] ? init_object (mm/slub.c:665)
> [  791.669480] setup_object.isra.34 (mm/slub.c:1008 mm/slub.c:1373)
> [  791.669480] new_slab (mm/slub.c:278 mm/slub.c:1412)

So we just got a new page from the page allocator but somehow cannot
write to it. This is the first write access to the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
