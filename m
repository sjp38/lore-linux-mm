Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F9E86B017C
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 12:12:08 -0400 (EDT)
Received: by iwn11 with SMTP id 11so2513872iwn.11
        for <linux-mm@kvack.org>; Sun, 14 Mar 2010 09:12:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4B9D0879.5050809@teksavvy.com>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
	 <4B8FC6AC.4060801@teksavvy.com>
	 <87f94c371003111029s7c7daebgf691ab11e6bdda25@mail.gmail.com>
	 <4B9D0879.5050809@teksavvy.com>
Date: Sun, 14 Mar 2010 12:12:06 -0400
Message-ID: <87f94c371003140912g1a567458ic2d78da6eed7fdb3@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: Greg Freemyer <greg.freemyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mark Lord <kernel@teksavvy.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, foo saa <foosaa@gmail.com>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 14, 2010 at 12:02 PM, Mark Lord <kernel@teksavvy.com> wrote:
> On 03/11/10 13:29, Greg Freemyer wrote:
>>>
>>> But really.. isn't "hdparm --security-erase NULL /dev/sdX" good enough
>>> ???
>>>
>>
>> This thread seems to have died off. =A0If there is a real problem, I
>> hope it picks back up.
>>
>> Mark, as to your question the few times I've tried that the bios on
>> the test machine blocked the command. =A0So it may have some specific
>> utility, but it's a not a generic solution in my mind.
>
> ..
>
> Yeah, a lot of BIOSs do a "SECURITY FREEZE" command before booting,
> which disables things like "SECURITY ERASE" until the next hard reset.
>
> So, on a Linux system, just unplug the drive after booting, replug it,
> and usually it can then be erased.

I have a client that wipes 10,000+ drives a month. (They do this as a
service to banks, etc. as the machines they're in are retired, so they
use 10,000+ machines to wipe those 10,000+ drives.)

They tend not to open the case, just boot via PXE/USB/CD and run a wiping t=
ool.

Opening the case to do as you propose is not really acceptable.  Also
they still have a lot of IDE inside those retiring machines.

fyi: If the wipe fails for whatever reason, they do open the case and
physically remove/disable/sanitize the drive.

Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
