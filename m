Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 73E0E8D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 11:26:28 -0500 (EST)
Date: Fri, 18 Feb 2011 17:26:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
Message-ID: <20110218162623.GD4862@tiehlicka.suse.cz>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
 <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz>
 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
 <20110217163531.GF14168@elte.hu>
 <m1pqqqfpzh.fsf@fess.ebiederm.org>
 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
 <20110218122938.GB26779@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110218122938.GB26779@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 18-02-11 13:29:38, Michal Hocko wrote:
> On Thu 17-02-11 11:11:51, Linus Torvalds wrote:
> > On Thu, Feb 17, 2011 at 10:57 AM, Eric W. Biederman
> > <ebiederm@xmission.com> wrote:
> > >
> > > fedora 14
> > > ext4 on all filesystems
> > 
> > Your dmesg snippets had ext3 mentioned, though:
> > 
> >   <6>EXT3-fs (sda1): recovery required on readonly filesystem
> >   <6>EXT3-fs (sda1): write access will be enabled during recovery
> >   <6>EXT3-fs: barriers not enabled
> >   ..
> >   <6>EXT3-fs (sda1): recovery complete
> >   <6>EXT3-fs (sda1): mounted filesystem with ordered data mode
> >   <6>dracut: Mounted root filesystem /dev/sda1
> > 
> > not that I see that it should matter, but there's been some bigger
> > ext3 changes too (like the batched discard).
> > 
> > I don't really think ext3 is the issue, though.
> > 
> > > I was about to say this happens with DEBUG_PAGEALLOC enabled but it
> > > appears that options keeps eluding my fingers when I have a few minutes
> > > to play with it. ?Perhaps this time will be the charm.
> > 
> > Please do. You seem to be much better at triggering it than anybody
> > else. And do the DEBUG_LIST and DEBUG_SLUB_ON things too (even if the
> > DEBUG_LIST thing won't catch list_move())
> 
> I was able to reproduce (now it fired into dcopserver) with the
> following simple test case:
> 
> while true
> do
> 	rmmod iwl3945 iwlcore mac80211 cfg80211
> 	sleep 2
> 	modprobe iwl3945
> done
> 
> Now, I will try with the 2 patches patches in this thread. I will also
> turn on DEBUG_LIST and DEBUG_PAGEALLOC.

I am not able to reproduce with those 2 patches applied.

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
