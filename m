Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f178.google.com (mail-gg0-f178.google.com [209.85.161.178])
	by kanga.kvack.org (Postfix) with ESMTP id B8E3F6B0035
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 09:27:57 -0500 (EST)
Received: by mail-gg0-f178.google.com with SMTP id q2so800433ggc.9
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 06:27:57 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id 25si20839866yhd.227.2014.01.13.06.27.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 06:27:56 -0800 (PST)
Message-ID: <52D3F7E0.3030206@ti.com>
Date: Mon, 13 Jan 2014 09:27:44 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com> <529217C7.6030304@cogentembedded.com> <52935762.1080409@ti.com> <20131209165044.cf7de2edb8f4205d5ac02ab0@linux-foundation.org> <20131210005454.GX4360@n2100.arm.linux.org.uk> <52A66826.7060204@ti.com> <20140112105958.GA9791@n2100.arm.linux.org.uk> <52D2B7C8.4060103@ti.com> <20140113123733.GU15937@n2100.arm.linux.org.uk>
In-Reply-To: <20140113123733.GU15937@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-arm-kernel@lists.infradead.org

On Monday 13 January 2014 07:37 AM, Russell King - ARM Linux wrote:
> On Sun, Jan 12, 2014 at 10:42:00AM -0500, Santosh Shilimkar wrote:
>> On Sunday 12 January 2014 05:59 AM, Russell King - ARM Linux wrote:
>>> On Mon, Dec 09, 2013 at 08:02:30PM -0500, Santosh Shilimkar wrote:
>>>> On Monday 09 December 2013 07:54 PM, Russell King - ARM Linux wrote:
>>>>> The underlying reason is that - as I've already explained - ARM's __ffs()
>>>>> differs from other architectures in that it ends up being an int, whereas
>>>>> almost everyone else is unsigned long.
>>>>>
>>>>> The fix is to fix ARMs __ffs() to conform to other architectures.
>>>>>
>>>> I was just about to cross-post your reply here. Obviously I didn't think
>>>> this far when I made  $subject fix.
>>>>
>>>> So lets ignore the $subject patch which is not correct. Sorry for noise
>>>
>>> Well, here we are, a month on, and this still remains unfixed despite
>>> my comments pointing to what the problem is.  So, here's a patch to fix
>>> this problem the correct way.  I took the time to add some comments to
>>> these functions as I find that I wonder about their return values, and
>>> these comments make the patch a little larger than it otherwise would be.
>>>
>> The $subject warning fix [1] is already picked by Andrew with your ack
>> and its in his queue [2]
>>
>>> This patch makes their types match exactly with x86's definitions of
>>> the same, which is the basic problem: on ARM, they all took "int" values
>>> and returned "int"s, which leads to min() in nobootmem.c complaining.
>>>
>> Not sure if you missed the thread but the right fix was picked. Ofcourse
>> you do have additional clz optimisation in updated patch and some comments
>> on those functions.
> 
> The problem here is that the patch fixing this is going via akpm's tree
> (why?) yet you want the code which introduces the warning to be merged
> via my tree.
>
> It seems to me to be absolutely silly to have code introduce a warning
> yet push the fix for the warning via a completely different tree...
> 
I mixed it up. Sorry. Some how I thought there was some other build
configuration thrown the same warning with memblock series and hence
suggested the patch to go via Andrew's tree.

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
