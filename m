Date: Tue, 10 Jun 2008 05:02:34 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 05/21] hugetlb: new sysfs interface
Message-ID: <20080610030234.GE19404@wotan.suse.de>
References: <20080604112939.789444496@amd.local0.net> <20080604113111.647714612@amd.local0.net> <20080608115941.746732a5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080608115941.746732a5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, nacc@us.ibm.com, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 08, 2008 at 11:59:41AM -0700, Andrew Morton wrote:
> On Wed, 04 Jun 2008 21:29:44 +1000 npiggin@suse.de wrote:
> 
> > Provide new hugepages user APIs that are more suited to multiple hstates in
> > sysfs. There is a new directory, /sys/kernel/hugepages. Underneath that
> > directory there will be a directory per-supported hugepage size, e.g.:
> > 
> > /sys/kernel/hugepages/hugepages-64kB
> > /sys/kernel/hugepages/hugepages-16384kB
> > /sys/kernel/hugepages/hugepages-16777216kB
> 
> Maybe /sys/mm or /sys/vm would be a more appropriate place.

I'm thinking all the random kernel subsystems under /sys/ should
rather be moved to /sys/kernel/. Imagine how much crap will be
under the root directory if every kernel subsystem goes there.

The system is the kernel, afterall, the subsystems should be under
there (arguably /sys/kernel/mm/hugepages/ would be better again, in
fact yes Nish can we do that?).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
