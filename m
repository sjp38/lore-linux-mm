Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C3D6D8D0048
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 12:57:16 -0500 (EST)
Message-ID: <4D484973.6080603@redhat.com>
Date: Tue, 01 Feb 2011 12:57:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mlock: operate on any regions with protection != PROT_NONE
References: <20110201010341.GA21676@google.com> <AANLkTinG7eHR1_kfEyvJYw52ngyvqv5UzigEOddsi9ye@mail.gmail.com>
In-Reply-To: <AANLkTinG7eHR1_kfEyvJYw52ngyvqv5UzigEOddsi9ye@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tao Ma <tm@tao.ma>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On 02/01/2011 12:59 AM, Linus Torvalds wrote:
> On Tue, Feb 1, 2011 at 11:03 AM, Michel Lespinasse<walken@google.com>  wrote:
>>
>> I am proposing to let mlock ignore vma protection in all cases except
>> PROT_NONE.
>
> What's so special about PROT_NONE? If you want to mlock something
> without actually being able to then fault that in, why not?
>
> IOW, why wouldn't it be right to just make FOLL_FORCE be unconditional in mlock?

I could think of a combination of reasons.

Specifically, some libc/linker magic will set up PROT_NONE
areas for programs automatically.

Some programs use mlockall to lock themselves into memory,
with no idea that PROT_NONE areas were set up behind its
back.

Faulting in the PROT_NONE memory will result is wasted
memory, without the application even realizing it.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
