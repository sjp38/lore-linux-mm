Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B7A6F6B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 09:01:06 -0500 (EST)
Received: by fxm22 with SMTP id 22so118696fxm.6
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 06:01:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201002261232.28686.elendil@planet.nl>
References: <201002261232.28686.elendil@planet.nl>
Date: Fri, 26 Feb 2010 16:01:49 +0200
Message-ID: <84144f021002260601o7ab345fer86b8bec12dbfc31e@mail.gmail.com>
Subject: Re: Memory management woes - order 1 allocation failures
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 26, 2010 at 1:32 PM, Frans Pop <elendil@planet.nl> wrote:
> Attached a long series of order 1 (!) page allocation failures with .33-rc7
> on an arm NAS box (running Debian unstable).
>
> The first failure occurred while running aptitude (Debian package manager)
> only ~20 minutes after booting the system, and I've seen that happen twice
> before.
>
> The other failures were all 1.5 days later while rsyncing a lot of music
> files (ogg/mp3) from another box to this one.
> They occurred when I was trying to also do something in an SSH session. The
> first ones from a simple 'sudo vi /etc/exports', some of the later ones
> while creating a new SSH session from my laptop.
>
> As can be seen from the attached munin graph [1] the system has only 256 MB
> memory, but that's quite normal for a simple NAS system. Only very little
> of that was in use by apps; most was being used for cache.
> The errors occurred in the area immediately above the "Thu 12:00" label,
> where the cache increases dramatically.
>
> Isn't it a bit strange that cache claims so much memory that real processes
> get into allocation failures?

All of the failed allocations seem to be GFP_ATOMIC so it's not _that_
strange. Dunno if anything changed recently. What's the last known
good kernel for you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
