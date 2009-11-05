Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 98A3B6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:27:08 -0500 (EST)
Date: Thu, 5 Nov 2009 16:26:26 +0100
Subject: Re: OOM killer, page fault
Message-ID: <20091105152626.GD21659@gamma.logic.tuwien.ac.at>
References: <20091030063216.GA30712@gamma.logic.tuwien.ac.at> <20091102005218.8352.A69D9226@jp.fujitsu.com> <20091102135640.93de7c2a.minchan.kim@barrios-desktop> <28c262360911012300h4535118ewd65238c746b91a52@mail.gmail.com> <20091102155543.E60E.A69D9226@jp.fujitsu.com> <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com> <20091102141917.GJ2116@gamma.logic.tuwien.ac.at> <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com> <20091105132109.GA12676@gamma.logic.tuwien.ac.at> <28c262360911050719u4de4223eub08c0f7ea8797137@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360911050719u4de4223eub08c0f7ea8797137@mail.gmail.com>
From: Norbert Preining <preining@logic.at>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Kim,

> > sorry for the late reply. I have two news, one good and one bad: The good
> > being that I can reproduce the bug by running VirtualBox with some W7
> 
> W7 means "Windows 7"?

Yes, sorry for the shorthand.

> > I know it sounds completely crazy, the patch only does harmless things
> > afais. But I tried it. Several times. rc6+patch never did boot, while
> > rc5 without path did boot. Then I patched it into -rc5, recompiled, and
> > boom, no boot. booting into .31.5, recompiling rc6 and rc5 without
> > that patch and suddenly rc6 boots (and I am sure rc5, too).
> 
> Hmm. It's out of my knowledge.
> Probably, It's because WARN_ON?
> Could you try it with omitting WARN_ON, again?

Will do that.

> > Ah yes, I can reproduce the original strange bug with oom killer!
> 
> Sounds good to me.
> Could you tell me your test scenario, your system info(CPU, RAM) and
> config?
> I want to reproduce it in my mahchine to not bother you. :)

Puhh, well, I meant "I could reproduce it", but not "I have a clear
idea what steps to be taken to reproduce it" ;-) Well here is what I can
tell you:
actual hardware:
Intel(R) Core(TM)2 Duo CPU     P9500
Memory 2G
Config of my kernel attached.

Virtual Machine (VirtualBox, not the OSE variant, I need USB 2.0 support
for GPS stuff):
VirtualBox 3.0.10
memory for the machine: 1G (50%)
ACPI and IO/APIC turned on
1 processor with PAE/NX
VT-x and Nested Paging activated
Display 128M
(need more details?)

I will remove the WARN_ON and reboot and see if that works. If yes I try
to recreate the problem.

Best wishes

Norbert

-------------------------------------------------------------------------------
Dr. Norbert Preining                                        Associate Professor
JAIST Japan Advanced Institute of Science and Technology   preining@jaist.ac.jp
Vienna University of Technology                               preining@logic.at
Debian Developer (Debian TeX Task Force)                    preining@debian.org
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 09C5 B094
-------------------------------------------------------------------------------
BROMSGROVE
Any urban environment containing a small amount of dogturd and about
forty-five tons of bent steel pylon or a lump of concrete with holes
claiming to be sculpture. 'Oh, come my dear, and come with me. And
wander 'neath the bromsgrove tree' - Betjeman.
			--- Douglas Adams, The Meaning of Liff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
