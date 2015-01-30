Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D412A6B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 12:21:29 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so54661605pac.13
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:21:29 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id by8si14490634pab.69.2015.01.30.09.21.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 30 Jan 2015 09:21:28 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ000LD232JXWB0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Jan 2015 17:25:31 +0000 (GMT)
Message-id: <54CBBD8C.8080907@samsung.com>
Date: Fri, 30 Jan 2015 20:21:16 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v10 15/17] kernel: add support for .init_array.*
 constructors
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-16-git-send-email-a.ryabinin@samsung.com>
 <20150129151301.006abdbcf9e0dd136dd6ed2f@linux-foundation.org>
In-reply-to: <20150129151301.006abdbcf9e0dd136dd6ed2f@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On 01/30/2015 02:13 AM, Andrew Morton wrote:
> On Thu, 29 Jan 2015 18:11:59 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> KASan uses constructors for initializing redzones for global
>> variables. Actually KASan doesn't need priorities for constructors,
>> so they were removed from GCC 5.0, but GCC 4.9.2 still generates
>> constructors with priorities.
> 
> I don't understand this changelog either.  What's wrong with priorities
> and what is the patch doing about it?  More details, please.
> 

Currently kernel ignore constructors with priorities (e.g. .init_array.00099).
Kernel understand only constructors with default priority ( .init_array ).

This patch adds support for constructors with priorities.

For kernel image we put pointers to constructors between __ctors_start/__ctors_end
and do_ctors() will call them.

For modules  - .init_array.* sections merged into .init_array section.
Module code properly handles constructors in .init_array section.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
