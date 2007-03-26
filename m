Date: Mon, 26 Mar 2007 12:48:46 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [linux-pm] [RFC] [PATCH] Power Managed memory base enabling
Message-ID: <20070326124846.GC11088@ucw.cz>
References: <20070305181826.GA21515@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070305181826.GA21515@linux.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Gross <mgross@linux.intel.com>
Cc: linux-mm@kvack.org, linux-pm@lists.osdl.org, mark.gross@intel.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

Hi!

> It implements a convention on the 4 bytes of "Proximity Domain ID"
> within the SRAT memory affinity structure as defined in ACPI3.0a.  If
> bit 31 is set, then the memory range represented by that PXM is assumed
> to be power managed.  We are working on defining a "standard" for
> identifying such memory areas as power manageable and progress committee
> based.  
...
> More will be done, but for now we would like to get this base enabling
> into the upstream kernel as an initial step.

I'm not sure if the hack above does not disqualify it from
mainstream...

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
