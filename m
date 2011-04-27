Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0759000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 06:28:54 -0400 (EDT)
Received: by iyh42 with SMTP id 42so1840362iyh.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 03:28:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
References: <20110424202158.45578f31@neptune.home>
	<20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
	<20110425111705.786ef0c5@neptune.home>
	<BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
	<20110425180450.1ede0845@neptune.home>
	<BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
Date: Wed, 27 Apr 2011 11:28:52 +0100
Message-ID: <BANLkTi==7UeCPf0WfD66f1jMXV7j8wsWEA@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
From: Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: =?UTF-8?Q?Bruno_Pr=C3=A9mont?= <bonbons@linux-vserver.org>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On 25 April 2011 17:31, Linus Torvalds <torvalds@linux-foundation.org> wrot=
e:
> 2011/4/25 Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>:
>> kmemleak reports 86681 new leaks between shortly after boot and -2 state=
.
>> (and 2348 additional ones between -2 and -4).
>
> I wouldn't necessarily trust kmemleak with the whole RCU-freeing
> thing. In your slubinfo reports, the kmemleak data itself also tends
> to overwhelm everything else - none of it looks unreasonable per se.

Kmemleak reports that it couldn't find any pointers to those objects
when scanning the memory. In theory, it is safe with RCU since objects
queued for freeing via the RCU are in a linked list and still
referred.

There are of course false positives, usually when pointers are stored
in some structures not scanned by kmemleak (e.g. some arrays allocated
with alloc_pages which are not explicitly tracked by kmemleak) but I
haven't seen any related to RCU (yet).

--=20
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
