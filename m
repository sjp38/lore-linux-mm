Message-ID: <004001bed91c$177667a0$c80c17ac@clmsdev.local>
From: "Manfred Spraul" <masp0008@stud.uni-sb.de>
Subject: Re: active_mm & SMP & TLB flush: possible bug
Date: Wed, 28 Jul 1999 18:58:58 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> BTW, where can I find more details about the active_mm implementation?
>> specifically, I'd like to know why active_mm was added to
>> "struct task_struct".
>> >From my first impression, it's a CPU specific information
>> (every CPU has exactly one active_mm, threads which are not running have
>> no
>> active_mm), so I'd have used a global array[NR_CPUS].
>
>That soulds like a good idea -- care to offer a patch? =)

I still try to understand the current implementation, and I can't propose a
patch before I understand the current code...

I'll try to write a patch over the weekend.


    Manfred





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
