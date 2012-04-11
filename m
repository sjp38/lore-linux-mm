Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 4F2CA6B004D
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 14:58:18 -0400 (EDT)
Received: by wibhq7 with SMTP id hq7so3924106wib.8
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 11:58:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120411184845.GA24831@tiehlicka.suse.cz>
References: <1334167824-19142-1-git-send-email-glommer@parallels.com> <20120411184845.GA24831@tiehlicka.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 11 Apr 2012 11:57:56 -0700
Message-ID: <CA+55aFx1GMWGgh0sTAzvvVSzPQsQ_4NKeaNv1zpKrP4fg1dG+Q@mail.gmail.com>
Subject: Re: [PATCH] remove BUG() in possible but rare condition
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Apr 11, 2012 at 11:48 AM, Michal Hocko <mhocko@suse.cz> wrote:
>
> I am not familiar with the code much but a trivial call chain walk up to
> write_dev_supers (in btrfs) shows that we do not check for the return value
> from __getblk so we would nullptr and there might be more.
> I guess these need some treat before the BUG might be removed, right?

Well, realistically, isn't BUG() as bad as a NULL pointer dereference?

Do you care about the exact message on the screen when your machine dies?

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
