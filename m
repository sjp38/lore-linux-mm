Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 77B466B004D
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 15:25:57 -0400 (EDT)
Date: Wed, 11 Apr 2012 21:25:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] remove BUG() in possible but rare condition
Message-ID: <20120411192554.GC24831@tiehlicka.suse.cz>
References: <1334167824-19142-1-git-send-email-glommer@parallels.com>
 <20120411184845.GA24831@tiehlicka.suse.cz>
 <CA+55aFx1GMWGgh0sTAzvvVSzPQsQ_4NKeaNv1zpKrP4fg1dG+Q@mail.gmail.com>
 <4F85D53B.1070806@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F85D53B.1070806@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 11-04-12 16:02:19, Glauber Costa wrote:
> On 04/11/2012 03:57 PM, Linus Torvalds wrote:
> >On Wed, Apr 11, 2012 at 11:48 AM, Michal Hocko<mhocko@suse.cz>  wrote:
> >>
> >>I am not familiar with the code much but a trivial call chain walk up to
> >>write_dev_supers (in btrfs) shows that we do not check for the return value
> >>from __getblk so we would nullptr and there might be more.
> >>I guess these need some treat before the BUG might be removed, right?
> >
> >Well, realistically, isn't BUG() as bad as a NULL pointer dereference?
> >
> >Do you care about the exact message on the screen when your machine dies?
> Not particular, but I don't see why (I might be wrong) it would
> necessarily lead to a NULL pointer dereference.

Ahh, OK scratch that. I have misread __getblk_slow which returns NULL
only if grow_buffers returned with < 0 which doesn't happen for the
allocation failure.

Sorry about noise
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
