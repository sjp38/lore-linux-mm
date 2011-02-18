Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F03D98D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 00:20:22 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20110216185234.GA11636@tiehlicka.suse.cz>
	<20110216193700.GA6377@elte.hu>
	<AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
	<AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
	<20110217090910.GA3781@tiehlicka.suse.cz>
	<AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	<20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	<AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	<m1sjvm822m.fsf@fess.ebiederm.org>
	<AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
Date: Thu, 17 Feb 2011 21:20:05 -0800
In-Reply-To: <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
	(Linus Torvalds's message of "Thu, 17 Feb 2011 20:30:42 -0800")
Message-ID: <m17hcx7wca.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Octavian Purdila <opurdila@ixiacom.com>, David Miller <davem@davemloft.net>, Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Thu, Feb 17, 2011 at 7:16 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> Interesting. =C2=A0I just got this with DEBUG_PAGEALLOC
>> It looks like something in DEBUG_PAGEALLOC is interfering with taking a
>> successful crashdump.
>
> Hmm. I don't see why, but we don't care. Just the IP and the Code:
> section is plenty good enough.

I agree that is a different problem.

I care because I don't get my automatic reboot after the crash.  Which
means things don't recover automatically, and I have to futz with the
machine.

> The patch from Eric Dumazet (which adds a few more cases to my patch
> and hopefully catches them all) almost certainly fixes this rather
> nasty memory corruption.

I will see if I can dig it up and get it into my test kernel.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
