Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id B93B56B004D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 08:08:37 -0500 (EST)
Date: Mon, 3 Dec 2012 14:08:34 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Fedora repo (was: Re: kswapd craziness in 3.7)
Message-ID: <20121203130834.GB32243@liondog.tnic>
References: <20121127222637.GG2301@cmpxchg.org>
 <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com>
 <20121128101359.GT8218@suse.de>
 <20121128145215.d23aeb1b.akpm@linux-foundation.org>
 <20121128235412.GW8218@suse.de>
 <50B77F84.1030907@leemhuis.info>
 <20121129170512.GI2301@cmpxchg.org>
 <50B8A8E7.4030108@leemhuis.info>
 <20121201004520.GK2301@cmpxchg.org>
 <50BC6314.7060106@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <50BC6314.7060106@leemhuis.info>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thorsten Leemhuis <fedora@leemhuis.info>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Ellson <john.ellson@comcast.net>

On Mon, Dec 03, 2012 at 09:30:12AM +0100, Thorsten Leemhuis wrote:
> Np; BTW, in case anybody here on LKML cares: I started maintaining a
> side repo (PPA in ubuntu speak) a few weeks ago that offers kernel
> vanilla builds (mainline and stable) for the Fedora 17 and 18; see
> https://fedoraproject.org/wiki/Kernel_Vanilla_Repositories
> for details. It's not as good and up2date yet as I would like it, but
> one has to start somewhere.

Once you have this ready, you should send a more official mail with
"[ANNOUNCE]" in its subject and containing explanations how to use the
repo to lkml and relevant lists so that more people know about it.

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
