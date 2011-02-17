Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BA1498D003A
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:31:26 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20110216185234.GA11636@tiehlicka.suse.cz>
	<20110216193700.GA6377@elte.hu>
	<AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
	<AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
	<20110217090910.GA3781@tiehlicka.suse.cz>
	<AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	<20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	<AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
Date: Thu, 17 Feb 2011 11:31:07 -0800
In-Reply-To: <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	(Linus Torvalds's message of "Thu, 17 Feb 2011 11:11:51 -0800")
Message-ID: <m1zkpue9vo.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Thu, Feb 17, 2011 at 10:57 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> fedora 14
>> ext4 on all filesystems
>
> Your dmesg snippets had ext3 mentioned, though:
>
>   <6>EXT3-fs (sda1): recovery required on readonly filesystem
>   <6>EXT3-fs (sda1): write access will be enabled during recovery
>   <6>EXT3-fs: barriers not enabled
>   ..
>   <6>EXT3-fs (sda1): recovery complete
>   <6>EXT3-fs (sda1): mounted filesystem with ordered data mode
>   <6>dracut: Mounted root filesystem /dev/sda1
>
> not that I see that it should matter, but there's been some bigger
> ext3 changes too (like the batched discard).
>
> I don't really think ext3 is the issue, though.

Oh right.  I changed the configuration but I haven't upgraded this
machine off of ext3 root yet.   The partition where all of the data is
going is ext4.  Creating a chrooted build environment on the fly is
great but it can momentarily swamp the disk.

>> I was about to say this happens with DEBUG_PAGEALLOC enabled but it
>> appears that options keeps eluding my fingers when I have a few minutes
>> to play with it. =C2=A0Perhaps this time will be the charm.
>
> Please do. You seem to be much better at triggering it than anybody
> else. And do the DEBUG_LIST and DEBUG_SLUB_ON things too (even if the
> DEBUG_LIST thing won't catch list_move())

DEBUG_LIST I did manage to get enabled and it didn't catch anything,
despite some bad PMD's showing up.  The other two should be enabled in
the kernel version I am building right now.

It does look like this can go quiet for a days at a time.  The 17th is
the first my logs show of it since the 14th.

messages:Feb 14 17:55:12 bs38 kernel: BUG: Bad page map in process [manager=
]  pte:ffff88028c45f748 pmd:28c45f067
messages:Feb 14 17:55:12 bs38 kernel: BUG: Bad page map in process [manager=
]  pte:ffff88028c45f748 pmd:28c45f067
messages:Feb 17 00:49:53 bs38 kernel: BUG: Bad page map in process Sysdb  p=
te:ffff8802742b3758 pmd:2742b3067
messages:Feb 17 00:49:53 bs38 kernel: BUG: Bad page map in process Sysdb  p=
te:ffff8802742b3758 pmd:2742b3067
messages:Feb 17 10:00:43 bs38 kernel: BUG: Bad page map in process cc1plus =
 pte:ffff880190f73758 pmd:190f73067
messages:Feb 17 10:00:43 bs38 kernel: BUG: Bad page map in process cc1plus =
 pte:ffff88025efed758 pmd:25efed067
messages:Feb 17 10:00:43 bs38 kernel: BUG: Bad page map in process cc1plus =
 pte:ffff88025efed758 pmd:25efed067
messages:Feb 17 10:00:43 bs38 kernel: BUG: Bad page map in process cc1plus =
 pte:ffff880190f73758 pmd:190f73067

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
