Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id A16296B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 13:05:37 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wm4so2112512obc.28
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 10:05:37 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id ds9si1106146obc.99.2014.01.08.10.05.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 10:05:36 -0800 (PST)
Message-ID: <52CD9366.2090200@ti.com>
Date: Wed, 8 Jan 2014 13:05:26 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86/mm: memblock: switch to use NUMA_NO_NODE
References: <20140107022559.GE14055@localhost> <1389198198-31027-1-git-send-email-grygorii.strashko@ti.com> <52CD8A9A.3010608@ti.com>
In-Reply-To: <52CD8A9A.3010608@ti.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>, Tejun Heo <tj@kernel.org>, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Wednesday 08 January 2014 12:27 PM, Grygorii Strashko wrote:
> Hi,
> 
> On 01/08/2014 06:23 PM, Grygorii Strashko wrote:
>> Update X86 code to use NUMA_NO_NODE instead of MAX_NUMNODES while
>> calling memblock APIs, because memblock API is changed to use NUMA_NO_NODE and
>> will produce warning during boot otherwise.
>>
>> See:
>>   https://lkml.org/lkml/2013/12/9/898
>>
> [...]
> 
> or, there are other 3 patches from Sergey Senozhatsky, which actually fix the same warnings:
>  https://lkml.org/lkml/2014/1/6/277 - [PATCH -next] x86 memtest: use NUMA_NO_NODE in do_one_pass()
>  https://lkml.org/lkml/2014/1/6/280 - [PATCH -next] e820: use NUMA_NO_NODE in memblock_find_dma_reserve()
>  http://comments.gmane.org/gmane.linux.kernel/1623429 - [PATCH -next] check: use NUMA_NO_NODE in setup_bios_corruption_check()
> 
Either one should be fine though $subject patch would be my personal preference.

Andrew,
This should kill at least 3 known memblock users with MAX_NUMNODES. Feel
free to pick the patch(s) as per your preference.

Regards,
Santosh




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
