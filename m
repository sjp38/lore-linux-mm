Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5F49C8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 11:35:45 -0500 (EST)
Date: Thu, 17 Feb 2011 17:35:31 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
Message-ID: <20110217163531.GF14168@elte.hu>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
 <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz>
 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> And in addition, I don't see why others wouldn't see it (I've got
> DEBUG_PAGEALLOC and SLUB_DEBUG_ON turned on myself, and I know others
> do too).

I've done extensive randconfig testing and no crash triggers for typical workloads 
on a typical dual-core PC. If there's a generic crashes in there my tests tend to 
trigger them at least 10x as often as regular testers ;-) But the tests are still 
only statistical so the race could simply be special and missed by the tests.

> So I'm wondering what triggers it. Must be something subtle.

I think what Michal did before he got the corruption seemed somewhat atypical: 
suspend/resume and udevd wifi twiddling, right?

Now, Eric's crashes look similar - and he does not seem to have done anything 
special to trigger the crashes.

Eric, could you possibly describe your system in a bit more detail, does it do 
suspend and does the box use wifi actively? Anything atypical in your setup or usage 
that doesnt match a bog-standard whitebox PC with LAN? Swap to file? NFS? FUSE? 
Anything that is even just borderline atypical.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
