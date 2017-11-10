Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE6EC440D03
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 02:41:23 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id l24so8277120pgu.17
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 23:41:23 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b89si807617pfc.304.2017.11.09.23.41.22
        for <linux-mm@kvack.org>;
        Thu, 09 Nov 2017 23:41:22 -0800 (PST)
Subject: Re: [PATCH v2] locking/lockdep: Revise
 Documentation/locking/crossrelease.txt
References: <1510212036-22008-1-git-send-email-byungchul.park@lge.com>
 <20171110073053.qh4nhpl26i47gbiv@gmail.com>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <2f2de6c8-ef4b-070d-a81d-eed677bcce35@lge.com>
Date: Fri, 10 Nov 2017 16:41:18 +0900
MIME-Version: 1.0
In-Reply-To: <20171110073053.qh4nhpl26i47gbiv@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

On 11/10/2017 4:30 PM, Ingo Molnar wrote:
> 
> * Byungchul Park <byungchul.park@lge.com> wrote:
> 
>>      Event C depends on event A.
>>      Event A depends on event B.
>>      Event B depends on event C.
>>   
>> -   NOTE: Precisely speaking, a dependency is one between whether a
>> -   waiter for an event can be woken up and whether another waiter for
>> -   another event can be woken up. However from now on, we will describe
>> -   a dependency as if it's one between an event and another event for
>> -   simplicity.
> 
> Why was this explanation removed?
> 
>> -Lockdep tries to detect a deadlock by checking dependencies created by
>> -lock operations, acquire and release. Waiting for a lock corresponds to
>> -waiting for an event, and releasing a lock corresponds to triggering an
>> -event in the previous section.
>> +Lockdep tries to detect a deadlock by checking circular dependencies
>> +created by lock operations, acquire and release, which are wait and
>> +event respectively.
> 
> What? You changed a readable paragraph into an unreadable one.
> 
> Sorry, this text needs to be acked by someone with good English skills, and I
> don't have the time right now to fix it all up. Please send minimal, obvious
> typo/grammar fixes only.

I will send one including minimal fixes at the next spin.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
