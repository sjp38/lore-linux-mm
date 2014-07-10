Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 37F046B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 09:20:51 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so10831942pde.17
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 06:20:50 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id ba17si8576393pdb.387.2014.07.10.06.20.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 10 Jul 2014 06:20:49 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8H008ELZQEJ950@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 Jul 2014 14:20:38 +0100 (BST)
Message-id: <53BE91E9.9090408@samsung.com>
Date: Thu, 10 Jul 2014 17:15:21 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 05/21] x86: cpu: don't sanitize early
 stages of a secondary CPU boot
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-6-git-send-email-a.ryabinin@samsung.com>
 <87egxunx8j.fsf@tassilo.jf.intel.com>
In-reply-to: <87egxunx8j.fsf@tassilo.jf.intel.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/09/14 23:33, Andi Kleen wrote:
> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
> 
>> Instrumentation of this files may result in unbootable machine.
> 
> This doesn't make sense. Is the code not NMI safe? 
> If yes that would need to be fixed because
> 
> Please debug more.
> 

Sure.
It turns out that  KASAN_SANITIZE_perf_event.o := n is not needed here.
The problem only with common.c

> perf is a common source of bugs (see Vice Weaver's fuzzer results),
> so it would be good to have this functionality for it.
> 
> -Andi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
