Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F3DC66B003A
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:13:37 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so10470265pad.7
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 08:13:37 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id gp10si28293342pbc.44.2014.09.10.08.13.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 08:13:37 -0700 (PDT)
Message-ID: <54106A58.50802@oracle.com>
Date: Wed, 10 Sep 2014 11:12:24 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH v2 00/10] Kernel address sainitzer (KASan) - dynamic
 memory error deetector.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-kbuild@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>

On 09/10/2014 10:31 AM, Andrey Ryabinin wrote:
> Hi,
> This is a second iteration of kerenel address sanitizer (KASan).

FWIW, I've been using v1 for a while and it has uncovered quite a few
real bugs across the kernel.

Some of them (I didn't go beyond the first page on google):

* https://lkml.org/lkml/2014/8/9/162 - Which resulted in major changes to
ballooning.
* https://lkml.org/lkml/2014/7/13/192
* https://lkml.org/lkml/2014/7/24/359


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
