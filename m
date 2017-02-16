Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 72239680FFB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 11:27:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 65so27577161pgi.7
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 08:27:54 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r19si7414321pfe.12.2017.02.16.08.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 08:27:53 -0800 (PST)
Subject: Re: [PATCH] mm,x86: fix SMP x86 32bit build for native_pud_clear()
References: <148719066814.31111.3239231168815337012.stgit@djiang5-desk3.ch.intel.com>
 <68216ac2-e194-30fa-9dcb-2020e8953bf5@linux.intel.com>
From: Dave Jiang <dave.jiang@intel.com>
Message-ID: <7280edbc-ba2b-2b72-680a-9408a8e764b9@intel.com>
Date: Thu, 16 Feb 2017 09:27:52 -0700
MIME-Version: 1.0
In-Reply-To: <68216ac2-e194-30fa-9dcb-2020e8953bf5@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, akpm@linux-foundation.org
Cc: keescook@google.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, vbabka@suse.cz, alexander.kapshuk@gmail.com



On 02/16/2017 08:42 AM, Dave Hansen wrote:
> On 02/15/2017 12:31 PM, Dave Jiang wrote:
>> The fix introduced by e4decc90 to fix the UP case for 32bit x86, however
>> that broke the SMP case that was working previously. Add ifdef so the dummy
>> function only show up for 32bit UP case only.
> 
> Could you elaborate a bit on how it broke things?

So originally 0-day build found that commit a10a1701 (mm, x86: add
support for PUD-sized transparent hugepages) is breaking 32bit x86 UP
config because native_pud_clear() was missing to satisfy
arch/x86/include/asm/pgtable.h. I added a dummy function to satisfy that
with commit e4decc90 (mm,x86: native_pud_clear missing on i386 build).
However in the process of doing that, I broke the 32bit x86 SMP config
that was working before.

> 
>> Fix: e4decc90 mm,x86: native_pud_clear missing on i386 build
> 
> Which tree is that in, btw?
> 
linux-next-20170214 I believe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
