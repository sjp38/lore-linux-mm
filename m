Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA0D6B01F6
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 15:14:52 -0400 (EDT)
Message-ID: <4C756BA0.2090700@zytor.com>
Date: Wed, 25 Aug 2010 12:14:40 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH 1/2] x86, mem: separate x86_64 vmalloc_sync_all()
 into separate functions
References: <4C6E4ECD.1090607@linux.intel.com> <87r5hni19y.fsf@basil.nowhere.org>
In-Reply-To: <87r5hni19y.fsf@basil.nowhere.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Haicheng Li <haicheng.li@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "ak@linux.intel.com" <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 08/25/2010 12:45 AM, Andi Kleen wrote:
> Haicheng Li <haicheng.li@linux.intel.com> writes:
> 
>> hello,
>>
>> Resend these two patches for bug fixing:
>>
>> The bug is that when memory hotplug-adding happens for a large enough area that a new PGD entry is
>> needed for the direct mapping, the PGDs of other processes would not get updated. This leads to some
>> CPUs oopsing when they have to access the unmapped areas, e.g. onlining CPUs on the new added node.
> 
> The patches look good to me. Can we please move forward with this?
> 
> Reviewed-by: Andi Kleen <ak@linux.intel.com>
> 

The patches are mangled so they don't apply even with patch -l --
Haicheng, could you send me another copy, as an attachment if necessary?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
