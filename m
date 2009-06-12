Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 817186B005C
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 13:54:21 -0400 (EDT)
Date: Fri, 12 Jun 2009 13:55:18 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when
	feature is disabled
Message-ID: <20090612175518.GE6417@mit.edu>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com> <20090612112258.GA14123@elte.hu> <20090612125741.GA6140@localhost> <20090612131754.GA32105@elte.hu> <20090612133352.GC6751@localhost> <20090612153620.GB23483@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612153620.GB23483@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 05:36:20PM +0200, Ingo Molnar wrote:
> > The data corruption has not caused real hurt yet, and can be 
> > isolated to prevent future accesses.  So it makes sense to just 
> > kill the impacted process(es).
> 
> Dunno, this just looks like a license to allow more crappy hardware, 
> hm? I'm all for _logging_ errors, but hwpoison is not about that: it 
> is about allowing the hardware to limp along in 'enterprise' setups, 
> with a (false looking) 'guarantee' that everything is fine.

This should be tunable; in some cases, logging it is the right thing
to do; I imagine that in the case of the desktop OS, the user would
appreciate being given *some* chance to save the document he or she
has spent the past hour working on before the system goes down "hard
and fast".

In other cases, the sysadmin is using a high-availability setup in an
enterprise deployment, and there he or she would want the system to
immediately shutdown so the hot standby can take over.

	    	     	    		    	 - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
