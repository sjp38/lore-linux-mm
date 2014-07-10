Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 227A26B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 10:08:45 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id q107so7478997qgd.27
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 07:08:44 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id q6si25150329qan.104.2014.07.10.07.08.43
        for <linux-mm@kvack.org>;
        Thu, 10 Jul 2014 07:08:43 -0700 (PDT)
Date: Thu, 10 Jul 2014 09:08:40 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC/PATCH RESEND -next 12/21] mm: util: move krealloc/kzfree
 to slab_common.c
In-Reply-To: <53BE4412.6030707@samsung.com>
Message-ID: <alpine.DEB.2.11.1407100908090.12483@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-13-git-send-email-a.ryabinin@samsung.com> <alpine.DEB.2.11.1407090931350.1384@gentwo.org> <53BE4412.6030707@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Thu, 10 Jul 2014, Andrey Ryabinin wrote:

> Should I send another patch to move this to slab_common.c?

Send one patch that is separte from this patchset to all slab
maintainers and include my ack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
