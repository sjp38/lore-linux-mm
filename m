Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 816D59000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 14:08:14 -0400 (EDT)
Date: Tue, 27 Sep 2011 13:08:09 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 1/2] mm: restrict access to slab files under procfs and
 sysfs
In-Reply-To: <20110927175453.GA3393@albatros>
Message-ID: <alpine.DEB.2.00.1109271304470.11361@router.home>
References: <20110927175453.GA3393@albatros>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

This also needs to other /proc files I believe,


Acked-by: Christoph Lameter <cl@linux.com>


Possible candidates:

christoph@oldy:~/n/linux-2.6$ grep proc_create mm/*
mm/swapfile.c:	proc_create("swaps", 0, NULL, &proc_swaps_operations);
mm/vmstat.c:	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
mm/vmstat.c:	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
mm/vmstat.c:	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
mm/vmstat.c:	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);

vmstat and zoneinfo in particular give similar information to what is
revealed through the slab proc files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
