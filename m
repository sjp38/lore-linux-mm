Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 50B726B005A
	for <linux-mm@kvack.org>; Tue, 29 May 2012 16:56:54 -0400 (EDT)
Date: Tue, 29 May 2012 16:49:59 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [GIT] (frontswap.v16-tag)
Message-ID: <20120529204959.GA21561@phenom.dumpdata.com>
References: <20120518204211.GA18571@localhost.localdomain>
 <20120524202221.GA19856@phenom.dumpdata.com>
 <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
 <20120529140244.GA3558@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120529140244.GA3558@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, chris.mason@oracle.com, matthew@wil.cx, ngupta@vflare.org, hannes@cmpxchg.org, hughd@google.com, sjenning@linux.vnet.ibm.com, JBeulich@novell.com, dan.magenheimer@oracle.com, linux-mm@kvack.org

> Also over the last couple of months I had gotten emails about people
> using it. Let me see if I can get their consent to either quote their
> emails or just ask them to reply to this thread.

Asked some of the folks to pipe in, but in the mean-time here are some links.

>From Oracle: Kurt Hackel says "interest in seeing frontswap merged upstream" because
it is already used in OracleVM.  https://lkml.org/lkml/2011/10/27/215
Avi Miller says "we see this as a critical feature."
https://lkml.org/lkml/2011/10/27/252 (product manager).

Some Android ports have picked it up [mainly to use zcache which depends on frontswap]:
- An LG and HTC kernel ROM has incorporated frontswap.
  http://androidforums.com/spectrum-all-things-root/522953-rom-5-26-12-broken-out-spectrum-3-0-w-blitzkrieg-kernel.html
- A GalaxyS-based kernel port has included frontswap.
  http://hdtechvideo.com/community/index.php?threads/devil2_0-94.245/
- CyanogenMod just added frontswap.
  http://www.andro9.in/2012/05/cyanogenmod-9-ics-404-weeklies-for-lg.html

Many people piped up last year at a previous merge proposal.  Here are some
from LKML postings:
- Brian King says IBM is actively looking at utilizing frontswap for
  IBM Power and would welcome its inclusion in mainline.
  https://lkml.org/lkml/2011/10/27/273
- Nitin Gupta, author of zram, has stated that zcache is in many ways
  superior to zram... but this assumes frontswap is merged.
  https://lkml.org/lkml/2011/10/28/8
- Ed Tomlinson says "I'd love to see this in the kernel."
  https://lkml.org/lkml/2011/10/29/53
- Sasha Levin and "CJ" worked on the KVM PoC and commented that
  https://lkml.org/lkml/2011/10/28/8
- Ed Tomlinson says "I'd love to see this in the kernel."
  https://lkml.org/lkml/2011/10/29/53
- While Andrea Arcangeli voiced objections last year 
  https://lkml.org/lkml/2011/10/31/186 he expressed at LSF/MM 2012
  that many of his issues are now resolved and sufficient progress
  has been made to merge frontswap (with more work needed in zcache
  before zcache can be promoted out of staging).
- James Bottomley requested more benchmarking on zcache and some
  excellent results were published and presented at LSF/MM 2012.
  http://lwn.net/Articles/490501/
- Valdis Kletnieks points out that he needs it in machines that
  are maxed out on RAM. https://lkml.org/lkml/2011/11/6/157

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
