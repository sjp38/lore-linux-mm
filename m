Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 224CC6B006E
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 12:08:50 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id g10so8525009pdj.41
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 09:08:49 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id v1si34885149pdm.171.2014.11.18.09.08.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 18 Nov 2014 09:08:48 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NF8008XIVRF5S10@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Nov 2014 17:11:40 +0000 (GMT)
Message-id: <546B7D1A.2020503@samsung.com>
Date: Tue, 18 Nov 2014 20:08:42 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory
 debugger.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>
 <5461B906.1040803@samsung.com>
In-reply-to: <5461B906.1040803@samsung.com>
Content-type: text/plain; charset=koi8-r
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org

On 11/11/2014 10:21 AM, Andrey Ryabinin wrote:
> Hi Andrew,
> 
> Now we have stable GCC(4.9.2) which supports kasan and from my point of view patchset is ready for merging.
> I could have sent v7 (it's just rebased v6), but I see no point in doing that and bothering people,
> unless you are ready to take it.
> So how should I proceed?
> 
Ping, Andrew ?

FWIW v7 will have one more patch needed for catching bad accesses in memcpy/memmove/memset.
Recently instrumentation of those functions was removed from GCC 5.0.



> Thanks,
> Andrey.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
