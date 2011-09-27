Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4F5F49000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 15:35:30 -0400 (EDT)
Date: Tue, 27 Sep 2011 14:35:25 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 1/2] mm: restrict access to slab files under procfs and
 sysfs
In-Reply-To: <20110927191658.GB4820@albatros>
Message-ID: <alpine.DEB.2.00.1109271431250.13797@router.home>
References: <20110927175453.GA3393@albatros> <alpine.DEB.2.00.1109271304470.11361@router.home> <20110927191658.GB4820@albatros>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, 27 Sep 2011, Vasiliy Kulikov wrote:

> On Tue, Sep 27, 2011 at 13:08 -0500, Christoph Lameter wrote:
> > Possible candidates:
> >
> > christoph@oldy:~/n/linux-2.6$ grep proc_create mm/*
> > mm/swapfile.c:	proc_create("swaps", 0, NULL, &proc_swaps_operations);
> > mm/vmstat.c:	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
> > mm/vmstat.c:	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
> > mm/vmstat.c:	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
> > mm/vmstat.c:	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
> >
> > vmstat and zoneinfo in particular give similar information to what is
> > revealed through the slab proc files.
>
> Do you know whether these files are actively used?  I don't want to
> break tools like "free" or "top".  In this case we'll have to discover
> another way to limit this information.

top uses per process information. Tried an strace and I see no access to
vmstat or zoneinfo.

free uses /proc/meminfo not vmstat or zoneinfo. Since you already have a
patch that limits /proc/meminfo access there is already an issue there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
