Message-ID: <001001bed928$35ebfd10$c80c17ac@clmsdev.local>
From: "Manfred Spraul" <masp0008@stud.uni-sb.de>
Subject: Re: active_mm & SMP & TLB flush: possible bug
Date: Wed, 28 Jul 1999 20:35:42 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Benjamin C.R. LaHaise <blah@kvack.org>
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org
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

I know you should not reply twice to one mail, but I noticed that my initial
assumption was wrong:
It seems that the MMU caches can contain data from multiple
"struct mm_struct"'s on the PPC cpu, perhaps this also applies to
other CPU's.
It's Intel specific that the TLB contains data from just one mm_struct.


--
    Manfred


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
