Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 797036B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 06:07:19 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so4670409pab.12
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 03:07:19 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id dn2si7490313pbc.160.2014.11.21.03.07.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 21 Nov 2014 03:07:17 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFD0017UZ0K4PA0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 21 Nov 2014 11:09:56 +0000 (GMT)
Message-id: <546F1CD1.3060600@samsung.com>
Date: Fri, 21 Nov 2014 14:06:57 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory
 debugger.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>
 <5461B906.1040803@samsung.com>
 <20141118125843.434c216540def495d50f3a45@linux-foundation.org>
 <CAPAsAGwZtfzx5oM73bOi_kw5BqXrwGd_xmt=m6xxU6uECA+H9Q@mail.gmail.com>
 <20141120090356.GA6690@gmail.com>
 <CACT4Y+aOKzq0AzvSJrRC-iU9LmmtLzxY=pxzu8f4oT-OZk=oLA@mail.gmail.com>
 <20141120150033.4cd1ca25be4a9b00a7074149@linux-foundation.org>
In-reply-to: <20141120150033.4cd1ca25be4a9b00a7074149@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/21/2014 02:00 AM, Andrew Morton wrote:
> On Thu, 20 Nov 2014 20:32:30 +0400 Dmitry Vyukov <dvyukov@google.com> wrote:
> 
>> Let me provide some background first.
> 
> Well that was useful.  Andrey, please slurp Dmitry's info into the 0/n
> changelog?
> 

Sure.

> Also, some quantitative info about the kmemleak overhead would be
> useful.
> 

Confused. Perhaps you mean kmemcheck?

I did some brief performance testing:

$ netperf -l 30

		MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost (127.0.0.1) port 0 AF_INET
		Recv   Send    Send
		Socket Socket  Message  Elapsed
		Size   Size    Size     Time     Throughput
		bytes  bytes   bytes    secs.    10^6bits/sec

no debug:	87380  16384  16384    30.00    41624.72

kasan inline:	87380  16384  16384    30.00    12870.54

kasan outline:	87380  16384  16384    30.00    10586.39

kmemcheck: 	87380  16384  16384    30.03      20.23


So on this workload kasan x500-x600 times faster then kmemcheck.


> In this discussion you've mentioned a few planned kasan enhancements. 
> Please also list those and attempt to describe the amount of effort and
> complexity levels.  Partly so other can understand the plans and partly
> so we can see what we're semi-committing ourselves to if we merge this
> stuff.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
