Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6364E6B0038
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 18:14:46 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id b13so5095180wgh.31
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 15:14:45 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id bw20si9484944wib.86.2014.11.20.15.14.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 15:14:45 -0800 (PST)
Date: Fri, 21 Nov 2014 00:14:20 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory
 debugger.
In-Reply-To: <20141120150033.4cd1ca25be4a9b00a7074149@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1411210011530.6439@nanos>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1415199241-5121-1-git-send-email-a.ryabinin@samsung.com> <5461B906.1040803@samsung.com> <20141118125843.434c216540def495d50f3a45@linux-foundation.org> <CAPAsAGwZtfzx5oM73bOi_kw5BqXrwGd_xmt=m6xxU6uECA+H9Q@mail.gmail.com>
 <20141120090356.GA6690@gmail.com> <CACT4Y+aOKzq0AzvSJrRC-iU9LmmtLzxY=pxzu8f4oT-OZk=oLA@mail.gmail.com> <20141120150033.4cd1ca25be4a9b00a7074149@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, 20 Nov 2014, Andrew Morton wrote:

> On Thu, 20 Nov 2014 20:32:30 +0400 Dmitry Vyukov <dvyukov@google.com> wrote:
> 
> > Let me provide some background first.
> 
> Well that was useful.  Andrey, please slurp Dmitry's info into the 0/n
> changelog?

And into Documentation/UBSan or whatever the favourite place is. 0/n
lengthy explanations have a tendecy to be hard to retrieve.

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
