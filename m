Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 57E056B016B
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 14:52:24 -0400 (EDT)
Date: Tue, 26 Jul 2011 20:52:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 2/2] mm: Switch NUMA_BUILD and COMPACTION_BUILD to
 new KCONFIG() syntax
Message-ID: <20110726185219.GC26597@tiehlicka.suse.cz>
References: <4E1D9C25.8080300@suse.cz>
 <1311634718-32588-1-git-send-email-mmarek@suse.cz>
 <1311634718-32588-2-git-send-email-mmarek@suse.cz>
 <20110726151908.GD17958@tiehlicka.suse.cz>
 <4E2F08A0.5080704@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E2F08A0.5080704@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Marek <mmarek@suse.cz>
Cc: linux-kbuild@vger.kernel.org, lacombar@gmail.com, sam@ravnborg.org, linux-kernel@vger.kernel.org, plagnioj@jcrosoft.com, linux-mm@kvack.org

On Tue 26-07-11 20:34:08, Michal Marek wrote:
> Dne 26.7.2011 17:19, Michal Hocko napsal(a):
> > On Tue 26-07-11 00:58:38, Michal Marek wrote:
> >> Cc: linux-mm@kvack.org
> >> Signed-off-by: Michal Marek <mmarek@suse.cz>
> > 
> > I assume that this is a cleanup. Without seeing the rest of the patch
> > set (probably not in linux-mm missing in the CC) and the cover email it
> > is hard to be sure. Could you add some description to the patch, please?
> 
> Sorry for the confusion. Patch 1/2 is here:
> https://lkml.org/lkml/2011/7/25/448 and provides a generic way to use
> CONFIG_* options in C expressions.

Yeah, google told me but the email was on its way already.

> This patch 2/2 for demonstration purposes only, if the first patch
> hits mainline, then I'll submit this one properly.

I like the change I am just afraid that this will make some hackery
easier.
In this particular case the code looks better and more grep friendly.

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
