Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 36738900015
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 11:07:04 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so5593573pdj.34
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 08:07:03 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id j5si9471813pdk.48.2014.11.21.08.07.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 21 Nov 2014 08:07:02 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFE00BD9CW5Q660@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 21 Nov 2014 16:09:41 +0000 (GMT)
Message-id: <546F6319.6010305@samsung.com>
Date: Fri, 21 Nov 2014 19:06:49 +0300
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
 <alpine.DEB.2.11.1411210011530.6439@nanos>
In-reply-to: <alpine.DEB.2.11.1411210011530.6439@nanos>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/21/2014 02:14 AM, Thomas Gleixner wrote:
> On Thu, 20 Nov 2014, Andrew Morton wrote:
> 
>> On Thu, 20 Nov 2014 20:32:30 +0400 Dmitry Vyukov <dvyukov@google.com> wrote:
>>
>>> Let me provide some background first.
>>
>> Well that was useful.  Andrey, please slurp Dmitry's info into the 0/n
>> changelog?
> 
> And into Documentation/UBSan or whatever the favourite place is. 0/n
> lengthy explanations have a tendecy to be hard to retrieve.
> 

I would rather put this into 1/n patch changelog.
IMO Documentation should only describe how to use this tool and how it works.

And UBSan != KASan. UBSan for detecting undefined behavior,
KASan for out of bounds and use after frees.

> Thanks,
> 
> 	tglx
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
