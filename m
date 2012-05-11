Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 9CE038D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 16:59:47 -0400 (EDT)
Date: Fri, 11 May 2012 16:59:13 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process wcg_gfam_6.11_i
Message-ID: <20120511205913.GA15539@redhat.com>
References: <bug-43227-27@https.bugzilla.kernel.org/>
 <20120511125921.a888e12c.akpm@linux-foundation.org>
 <20120511200213.GB7387@sli.dy.fi>
 <20120511133234.6130b69a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120511133234.6130b69a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Liedes <sami.liedes@iki.fi>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Fri, May 11, 2012 at 01:32:34PM -0700, Andrew Morton wrote:
 > On Fri, 11 May 2012 23:02:13 +0300
 > Sami Liedes <sami.liedes@iki.fi> wrote:
 > 
 > > On Fri, May 11, 2012 at 12:59:21PM -0700, Andrew Morton wrote:
 > > > > [67031.755786] BUG: Bad page state in process wcg_gfam_6.11_i  pfn:02519
 > > > > [67031.755790] page:ffffea0000094640 count:0 mapcount:0 mapping:         
 > > > > (null) index:0x7f1eb293b
 > > > > [67031.755792] page flags: 0x4000000000000014(referenced|dirty)
 > > > 
 > > > AFAICT we got this warning because the page allocator found a free page
 > > > with PG_referenced and PG_dirty set.
 > > > 
 > > > It would be a heck of a lot more useful if we'd been told about this
 > > > when the page was freed, not when it was reused!  Can anyone think of a
 > > > reason why PAGE_FLAGS_CHECK_AT_FREE doesn't include these flags (at
 > > > least)?
 > > 
 > > Would it be useful if I tried to reproduce this with some debugging
 > > options turned on, for example CONFIG_DEBUG_VM?
 > > 
 > 
 > Sure, thanks, that might turn something up. 
 > Documentation/SubmitChecklist recommends 
 > 
 > : 12: Has been tested with CONFIG_PREEMPT, CONFIG_DEBUG_PREEMPT,
 > :     CONFIG_DEBUG_SLAB, CONFIG_DEBUG_PAGEALLOC, CONFIG_DEBUG_MUTEXES,
 > :     CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_ATOMIC_SLEEP, CONFIG_PROVE_RCU
 > :     and CONFIG_DEBUG_OBJECTS_RCU_HEAD all simultaneously enabled.
 > 
 > although that list might be a bit out of date; it certainly should
 > include CONFIG_DEBUG_VM!

FWIW, that Fedora report of this had DEBUG_VM enabled, and it doesn't
seem that there was any earlier oops/warn judging by the lack of tainting.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
