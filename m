Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id A193E6B0031
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 10:47:20 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id a11so6166263qen.19
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 07:47:20 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id e7si19591291qez.74.2014.01.12.07.47.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 12 Jan 2014 07:47:19 -0800 (PST)
Message-ID: <52D2B8ED.2010006@ti.com>
Date: Sun, 12 Jan 2014 10:46:53 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com> <529217C7.6030304@cogentembedded.com> <52935762.1080409@ti.com> <20131209165044.cf7de2edb8f4205d5ac02ab0@linux-foundation.org> <20131210005454.GX4360@n2100.arm.linux.org.uk> <52A66826.7060204@ti.com> <20140112105958.GA9791@n2100.arm.linux.org.uk> <52D2B7C8.4060103@ti.com>
In-Reply-To: <52D2B7C8.4060103@ti.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Sunday 12 January 2014 10:42 AM, Santosh Shilimkar wrote:
> On Sunday 12 January 2014 05:59 AM, Russell King - ARM Linux wrote:
>> On Mon, Dec 09, 2013 at 08:02:30PM -0500, Santosh Shilimkar wrote:
>>> On Monday 09 December 2013 07:54 PM, Russell King - ARM Linux wrote:
>>>> The underlying reason is that - as I've already explained - ARM's __ffs()
>>>> differs from other architectures in that it ends up being an int, whereas
>>>> almost everyone else is unsigned long.
>>>>
>>>> The fix is to fix ARMs __ffs() to conform to other architectures.
>>>>
>>> I was just about to cross-post your reply here. Obviously I didn't think
>>> this far when I made  $subject fix.
>>>
>>> So lets ignore the $subject patch which is not correct. Sorry for noise
>>
>> Well, here we are, a month on, and this still remains unfixed despite
>> my comments pointing to what the problem is.  So, here's a patch to fix
>> this problem the correct way.  I took the time to add some comments to
>> these functions as I find that I wonder about their return values, and
>> these comments make the patch a little larger than it otherwise would be.
>>
> The $subject warning fix [1] is already picked by Andrew with your ack
> and its in his queue [2]
> 
>> This patch makes their types match exactly with x86's definitions of
>> the same, which is the basic problem: on ARM, they all took "int" values
>> and returned "int"s, which leads to min() in nobootmem.c complaining.
>>
> Not sure if you missed the thread but the right fix was picked. Ofcourse
> you do have additional clz optimisation in updated patch and some comments
> on those functions.
> 
> Regards,
> Santosh
> 
> [1] https://lkml.org/lkml/2013/12/9/811
fixing the link since above was the link to the $subject thread and below is
the correct link for updated patch
[1] https://lkml.org/lkml/2013/12/20/497
> [2] http://ozlabs.org/~akpm/mmotm/broken-out/mm-arm-fix-arms-__ffs-to-conform-to-avoid-warning-with-no_bootmem.patch
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
