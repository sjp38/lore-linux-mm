Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 67F786B0035
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 23:56:31 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so9619856pdj.30
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 20:56:31 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y3si30561758pda.0.2014.09.10.20.56.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 20:56:30 -0700 (PDT)
Message-ID: <54111D3B.6060609@oracle.com>
Date: Wed, 10 Sep 2014 23:55:39 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH v2 01/10] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-2-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1410359487-31938-2-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On 09/10/2014 10:31 AM, Andrey Ryabinin wrote:
> +ifdef CONFIG_KASAN
> +  ifeq ($(call cc-option, $(CFLAGS_KASAN)),)
> +    $(warning Cannot use CONFIG_KASAN: \
> +	      -fsanitize=kernel-address not supported by compiler)
> +  endif
> +endif

This seems to always indicate that my gcc doesn't support
-fsanitize=kernel-address:

Makefile:769: Cannot use CONFIG_KASAN: -fsanitize=kernel-address not supported by compiler

Even though:

$ gcc --version
gcc (GCC) 5.0.0 20140904 (experimental)
Copyright (C) 2014 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

$ cat test.c
#include <stdio.h>
#include <sys/mman.h>

void __asan_init_v3(void) { }

int main(int argc, char *argv[])
{
        return 0;
}
$ gcc -fsanitize=kernel-address test.c
$ ./a.out
$


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
