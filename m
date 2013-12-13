Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f42.google.com (mail-qe0-f42.google.com [209.85.128.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7CE6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 20:24:20 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id b4so1091545qen.29
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 17:24:20 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id b3si295352qab.125.2013.12.12.17.24.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 17:24:19 -0800 (PST)
Message-ID: <52AA61BF.9080204@ti.com>
Date: Thu, 12 Dec 2013 20:24:15 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 13/23] mm/lib/swiotlb: Use memblock apis for early
 memory allocations
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com> <1386625856-12942-14-git-send-email-santosh.shilimkar@ti.com> <20131212170857.e36d016a95992c932da824b0@linux-foundation.org>
In-Reply-To: <20131212170857.e36d016a95992c932da824b0@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thursday 12 December 2013 08:08 PM, Andrew Morton wrote:
> On Mon, 9 Dec 2013 16:50:46 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:
> 
>> Switch to memblock interfaces for early memory allocator instead of
>> bootmem allocator. No functional change in beahvior than what it is
>> in current code from bootmem users points of view.
>>
>> Archs already converted to NO_BOOTMEM now directly use memblock
>> interfaces instead of bootmem wrappers build on top of memblock. And the
>> archs which still uses bootmem, these new apis just fallback to exiting
>> bootmem APIs.
> 
> This one makes my x86_64 test box fail to boot.  There's no obvious
> indication why and I don't have netconsole on this machine, sorry.  It
> simply fails to mount the root fs.
> 
> config:
> 
Thanks for config and reporting the issue.
Unfortunately I don't have ability to test x86 machine but will
try to analyze it and find out whats could be going wrong.

Failure around rootfs mount means it could be something to do
with memory free related code from the patch.

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
