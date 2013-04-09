Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id DE5966B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:08:32 -0400 (EDT)
Message-ID: <51642EEB.1010204@parallels.com>
Date: Tue, 09 Apr 2013 19:08:27 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/1] mm: Another attempt to monitor task's memory
 changes
References: <515F0484.1010703@parallels.com> <20130408153024.4edbcb491f18c948adbe9fe8@linux-foundation.org>
In-Reply-To: <20130408153024.4edbcb491f18c948adbe9fe8@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Glauber Costa <glommer@parallels.com>, Matthew Wilcox <willy@linux.intel.com>

On 04/09/2013 02:30 AM, Andrew Morton wrote:
> On Fri, 05 Apr 2013 21:06:12 +0400 Pavel Emelyanov <xemul@parallels.com> wrote:
> 
>> Hello,
>>
>> This is another attempt (previous one was [1]) to implement support for 
>> memory snapshot for the the checkpoint-restore project (http://criu.org).
>> Let me remind what the issue is.
>>
>> << EOF
>> To create a dump of an application(s) we save all the information about it
>> to files, and the biggest part of such dump is the contents of tasks' memory.
>> However, there are usage scenarios where it's not required to get _all_ the
>> task memory while creating a dump. For example, when doing periodical dumps,
>> it's only required to take full memory dump only at the first step and then
>> take incremental changes of memory. Another example is live migration. We 
>> copy all the memory to the destination node without stopping all tasks, then
>> stop them, check for what pages has changed, dump it and the rest of the state,
>> then copy it to the destination node. This decreases freeze time significantly.
>>
>> That said, some help from kernel to watch how processes modify the contents
>> of their memory is required. Previous attempt used ftrace to inform userspace
>> about memory being written to. This one is different.
>>
>> EOF
> 
> Did you consider teaching the kernel to perform a strong hash on a
> page's contents so that userspace can do a before-and-after check to see
> if it changed?

I did (unless I misunderstood _your_ idea with hashes :( ), but judged, that
a single bit on a pte would be less cpu and memory consuming than calculating
and keeping 32/64 bits of hash value.


As far as all other comments are concerned -- thanks a LOT for the feedback!
I will address them all.


Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
