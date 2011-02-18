Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DEBE98D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 03:54:27 -0500 (EST)
Date: Fri, 18 Feb 2011 09:54:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
Message-ID: <20110218085425.GB10846@tiehlicka.suse.cz>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
 <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz>
 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
 <20110217163531.GF14168@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110217163531.GF14168@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 17-02-11 17:35:31, Ingo Molnar wrote:
> 
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > And in addition, I don't see why others wouldn't see it (I've got
> > DEBUG_PAGEALLOC and SLUB_DEBUG_ON turned on myself, and I know others
> > do too).
> 
> I've done extensive randconfig testing and no crash triggers for typical workloads 
> on a typical dual-core PC. If there's a generic crashes in there my tests tend to 
> trigger them at least 10x as often as regular testers ;-) But the tests are still 
> only statistical so the race could simply be special and missed by the tests.
> 
> > So I'm wondering what triggers it. Must be something subtle.
> 
> I think what Michal did before he got the corruption seemed somewhat atypical: 
> suspend/resume and udevd wifi twiddling, right?

I wouldn't call it atypical. I just resumed from suspend to RAM and set
up my wireless interface which involved modprobe for iwlwifi[*] (where udev
came into play).

---
[*] - my script for setting up home wireless connection rmmods iwlwifi,
iwlcore mac80211 cfg80211 and then modprobes iwlwifi. It is a relict
from the past where I wasn't able to re-establish the connection in some
cases (well stupid router which totally confused the driver) without
reloading modules. I guess this is no more needed but I was lazy to
touch my scripts when they work.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
