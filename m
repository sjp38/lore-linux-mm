Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7B46B0039
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 16:38:29 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so9671676pad.26
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 13:38:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ta1si46906444pac.50.2014.07.09.13.38.27
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 13:38:28 -0700 (PDT)
Message-ID: <53BDA841.4000400@intel.com>
Date: Wed, 09 Jul 2014 13:38:25 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/09/2014 04:29 AM, Andrey Ryabinin wrote:
> +config KASAN
> +	bool "AddressSanitizer: dynamic memory error detector"
> +	default n
> +	help
> +	  Enables AddressSanitizer - dynamic memory error detector,
> +	  that finds out-of-bounds and use-after-free bugs.

This definitely needs some more text like "This option eats boatloads of
memory and will slow your system down enough that it should never be
used in production unless you are crazy".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
