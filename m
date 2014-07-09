Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id BD1DD6B003B
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 16:40:59 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so3420267wiv.2
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 13:40:59 -0700 (PDT)
Received: from mail-we0-x231.google.com (mail-we0-x231.google.com [2a00:1450:400c:c03::231])
        by mx.google.com with ESMTPS id dg3si47871766wjb.66.2014.07.09.13.40.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 13:40:59 -0700 (PDT)
Received: by mail-we0-f177.google.com with SMTP id u56so8019062wes.22
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 13:40:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87pphenxex.fsf@tassilo.jf.intel.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
	<87pphenxex.fsf@tassilo.jf.intel.com>
Date: Thu, 10 Jul 2014 00:40:58 +0400
Message-ID: <CAJOtW+5=5EGwLyAA+33y4E9UGuGHuXQkf6rTEsh0e7rqoNBKCg@mail.gmail.com>
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer infrastructure.
From: Yuri Gribov <tetra2005@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Wed, Jul 9, 2014 at 11:29 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Hardcoding --param is not very nice. They can change from compiler
> to compiler version. Need some version checking?

We plan to address this soon. CFLAGS will look more like
-fsanitize=kernel-address but this flag is not yet in gcc.

-Y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
