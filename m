Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id A96016B004D
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 11:31:14 -0500 (EST)
Received: by mail-oa0-f54.google.com with SMTP id o6so2028668oag.13
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 08:31:14 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id kv3si931696obb.71.2014.01.08.08.31.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 08:31:13 -0800 (PST)
Message-ID: <52CD8A9A.3010608@ti.com>
Date: Wed, 8 Jan 2014 19:27:54 +0200
From: Grygorii Strashko <grygorii.strashko@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86/mm: memblock: switch to use NUMA_NO_NODE
References: <20140107022559.GE14055@localhost> <1389198198-31027-1-git-send-email-grygorii.strashko@ti.com>
In-Reply-To: <1389198198-31027-1-git-send-email-grygorii.strashko@ti.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, santosh.shilimkar@ti.com
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Tejun Heo <tj@kernel.org>, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

Hi,

On 01/08/2014 06:23 PM, Grygorii Strashko wrote:
> Update X86 code to use NUMA_NO_NODE instead of MAX_NUMNODES while
> calling memblock APIs, because memblock API is changed to use NUMA_NO_NODE and
> will produce warning during boot otherwise.
> 
> See:
>   https://lkml.org/lkml/2013/12/9/898
> 
[...]

or, there are other 3 patches from Sergey Senozhatsky, which actually fix the same warnings:
 https://lkml.org/lkml/2014/1/6/277 - [PATCH -next] x86 memtest: use NUMA_NO_NODE in do_one_pass()
 https://lkml.org/lkml/2014/1/6/280 - [PATCH -next] e820: use NUMA_NO_NODE in memblock_find_dma_reserve()
 http://comments.gmane.org/gmane.linux.kernel/1623429 - [PATCH -next] check: use NUMA_NO_NODE in setup_bios_corruption_check()

Regards,
- grygorii


	



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
