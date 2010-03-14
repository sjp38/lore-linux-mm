Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7A0FD6B017B
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 12:02:03 -0400 (EDT)
Message-ID: <4B9D0879.5050809@teksavvy.com>
Date: Sun, 14 Mar 2010 12:02:01 -0400
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
Subject: Re: Linux kernel - Libata bad block error handling to user mode
 program
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>	 <4B8FC6AC.4060801@teksavvy.com> <87f94c371003111029s7c7daebgf691ab11e6bdda25@mail.gmail.com>
In-Reply-To: <87f94c371003111029s7c7daebgf691ab11e6bdda25@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Freemyer <greg.freemyer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, foo saa <foosaa@gmail.com>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/11/10 13:29, Greg Freemyer wrote:
>>
>> But really.. isn't "hdparm --security-erase NULL /dev/sdX" good enough ???
>>
>
> This thread seems to have died off.  If there is a real problem, I
> hope it picks back up.
>
> Mark, as to your question the few times I've tried that the bios on
> the test machine blocked the command.  So it may have some specific
> utility, but it's a not a generic solution in my mind.
..

Yeah, a lot of BIOSs do a "SECURITY FREEZE" command before booting,
which disables things like "SECURITY ERASE" until the next hard reset.

So, on a Linux system, just unplug the drive after booting, replug it,
and usually it can then be erased.

But yeah.. that all makes things tricker for non-techies.

Cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
