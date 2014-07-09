Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 57E186B0036
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 15:33:19 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so9380119pde.26
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 12:33:19 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ry2si19235097pbc.106.2014.07.09.12.33.17
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 12:33:18 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC/PATCH RESEND -next 05/21] x86: cpu: don't sanitize early stages of a secondary CPU boot
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1404905415-9046-6-git-send-email-a.ryabinin@samsung.com>
Date: Wed, 09 Jul 2014 12:33:16 -0700
In-Reply-To: <1404905415-9046-6-git-send-email-a.ryabinin@samsung.com> (Andrey
	Ryabinin's message of "Wed, 09 Jul 2014 15:29:59 +0400")
Message-ID: <87egxunx8j.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

Andrey Ryabinin <a.ryabinin@samsung.com> writes:

> Instrumentation of this files may result in unbootable machine.

This doesn't make sense. Is the code not NMI safe? 
If yes that would need to be fixed because

Please debug more.

perf is a common source of bugs (see Vice Weaver's fuzzer results),
so it would be good to have this functionality for it.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
