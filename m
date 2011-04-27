Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 982516B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:13:02 -0400 (EDT)
Date: Wed, 27 Apr 2011 23:12:58 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 2/3] support for broken memory modules (BadRAM)
Message-ID: <20110427211258.GQ16484@one.firstfloor.org>
References: <1303921007-1769-1-git-send-email-sassmann@kpanic.de> <1303921007-1769-3-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1303921007-1769-3-git-send-email-sassmann@kpanic.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Assmann <sassmann@kpanic.de>
Cc: linux-mm@kvack.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org, lwoodman@redhat.com, riel@redhat.com

On Wed, Apr 27, 2011 at 06:16:46PM +0200, Stefan Assmann wrote:
> BadRAM is a mechanism to exclude memory addresses (pages) from being used by
> the system. The addresses are given to the kernel via kernel command line.
> This is useful for systems with defective RAM modules, especially if the RAM
> modules cannot be replaced.
> 
> command line parameter: badram=<addr>,<mask>[,...]
> 
> Patterns for the command line parameter can be obtained by running Memtest86.
> In Memtest86 press "c" for configuration, select "Error Report Mode" and
> finally "BadRAM Patterns"
> 
> This has already been done by Rick van Rein a long time ago but it never found
> it's way into the kernel.

Looks good to me, except for the too verbose printks. Logging
every page this way will be very noisy for larger areas.

The mask will also only work for very simple memory interleaving
setups, so I suspect it won't work for a lot of modern systems
unless you go more fancy.

Longer term there should be also likely a better way to specify
these pages than the kernel command line, e.g. the new persistent
store on some systems.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
