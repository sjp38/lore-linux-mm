Received: by fg-out-1718.google.com with SMTP id e12so453911fga.4
        for <linux-mm@kvack.org>; Wed, 19 Mar 2008 17:16:49 -0700 (PDT)
Date: Thu, 20 Mar 2008 01:15:20 +0100
From: Diego Calleja <diegocg@gmail.com>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-Id: <20080320011520.60e151be.diegocg@gmail.com>
In-Reply-To: <20080319020440.80379d50.akpm@linux-foundation.org>
References: <20080318209.039112899@firstfloor.org>
	<20080318003620.d84efb95.akpm@linux-foundation.org>
	<20080318141828.GD11966@one.firstfloor.org>
	<20080318095715.27120788.akpm@linux-foundation.org>
	<20080318172045.GI11966@one.firstfloor.org>
	<20080318104437.966c10ec.akpm@linux-foundation.org>
	<20080319083228.GM11966@one.firstfloor.org>
	<20080319020440.80379d50.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

El Wed, 19 Mar 2008 02:04:40 -0700, Andrew Morton <akpm@linux-foundation.org> escribio:

> Assuming that all users have the same access pattern might be inefficient,
> a little bit.  There might be some advantage to making it per-user, dunno.

In the Dark Side of operating systems, the prefetching system they use
can log several access patterns for a single executable, because a single
executable can have different behaviours even for the same user, depending
on what parameters the executable is passed and what COM machinery it
uses. For example, wmplayer.exe can play a dvd, rip a CD, listen to a music
stream, etc...diferent usages, different access patterns. Linux probably faces
the same problem (bash, cat...)

A alternative design for a userspace solution that doesn't needs LD_PRELOAD
is to use CONFIG_PROC_EVENTS to get notifications of what processes are
started, which can be used to poll its /proc files or try to preload data
(asynchronously, and a bit hacky maybe).

But if a kernel patch is really needed to implement this properly, maybe
it'd be worth to take a look at the prefetch project that the Ubuntu guys
are apparently going to merge in the next ubuntu development release (8.10)...
https://wiki.ubuntu.com/DesktopTeam/Specs/Prefetch

There are even kernel patches:
http://code.google.com/p/prefetch/source/browse/tags/soc2007-end/trunk/kernel-patches/2.6.22/submitted/0001-prefetch-core.diff
http://code.google.com/p/prefetch/source/browse/tags/soc2007-end/trunk/kernel-patches/2.6.22/submitted/0002-prefetch-boot.diff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
