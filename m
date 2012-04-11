Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 402BC6B0044
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 17:33:10 -0400 (EDT)
Date: Wed, 11 Apr 2012 23:33:07 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] remove BUG() in possible but rare condition
In-Reply-To: <CA+55aFx1GMWGgh0sTAzvvVSzPQsQ_4NKeaNv1zpKrP4fg1dG+Q@mail.gmail.com>
Message-ID: <alpine.LRH.2.00.1204112331290.1415@twin.jikos.cz>
References: <1334167824-19142-1-git-send-email-glommer@parallels.com> <20120411184845.GA24831@tiehlicka.suse.cz> <CA+55aFx1GMWGgh0sTAzvvVSzPQsQ_4NKeaNv1zpKrP4fg1dG+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 11 Apr 2012, Linus Torvalds wrote:

> > I am not familiar with the code much but a trivial call chain walk up to
> > write_dev_supers (in btrfs) shows that we do not check for the return value
> > from __getblk so we would nullptr and there might be more.
> > I guess these need some treat before the BUG might be removed, right?
> 
> Well, realistically, isn't BUG() as bad as a NULL pointer dereference?

Well, there still could be weirdos out there not setting 
sys.vm.mmap_min_addr to something sane. For those, NULL pointer 
dereference could have worse consequences than BUG (unlikely in this 
particular case, yes).

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
