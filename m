Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 440C46B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 20:26:34 -0400 (EDT)
Date: Sun, 13 May 2012 20:25:57 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process wcg_gfam_6.11_i
Message-ID: <20120514002557.GA13658@redhat.com>
References: <bug-43227-27@https.bugzilla.kernel.org/>
 <20120511125921.a888e12c.akpm@linux-foundation.org>
 <20120511200213.GB7387@sli.dy.fi>
 <20120511133234.6130b69a.akpm@linux-foundation.org>
 <20120511222341.GD7387@sli.dy.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120511222341.GD7387@sli.dy.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sami Liedes <sami.liedes@iki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Sat, May 12, 2012 at 01:23:41AM +0300, Sami Liedes wrote:
 > On Fri, May 11, 2012 at 01:32:34PM -0700, Andrew Morton wrote:
 > > Sure, thanks, that might turn something up. 
 > > Documentation/SubmitChecklist recommends 
 > > 
 > > : 12: Has been tested with CONFIG_PREEMPT, CONFIG_DEBUG_PREEMPT,
 > > :     CONFIG_DEBUG_SLAB, CONFIG_DEBUG_PAGEALLOC, CONFIG_DEBUG_MUTEXES,
 > > :     CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_ATOMIC_SLEEP, CONFIG_PROVE_RCU
 > > :     and CONFIG_DEBUG_OBJECTS_RCU_HEAD all simultaneously enabled.
 > > 
 > > although that list might be a bit out of date; it certainly should
 > > include CONFIG_DEBUG_VM!
 > 
 > I wonder if there's somewhere a recommended list of generally most
 > useful debug options that only have a moderate performance impact? I'd
 > be happy to use a set of useful debug flags that generally impacts
 > performance by, say, <10%, on the computers I use for my everyday work
 > to help catch bugs. But it's sometimes quite hard to assess the impact
 > of different Kernel hacking options from just the description...

One problem here is that acceptable performance is entirely subjective,
based on your individual workload.  For example, I nearly always run
the fedora 'debug' builds, which enable near every debug option, and
don't find it particularly painful. Other people find those same builds
completely intolerable. Especially for example users of shiny new desktops
that rely heavily on the drm. Seems that code is particularly miserable
to use when spinlock debugging/lockdep are enabled.

A few releases back, something changed which made debug builds even more
'heavyweight' for some users. Still haven't figured out what that might be.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
