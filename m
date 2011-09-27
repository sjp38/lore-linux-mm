Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 33DFB9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 15:17:54 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so9673916bkb.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 12:17:51 -0700 (PDT)
Date: Tue, 27 Sep 2011 23:16:58 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH 1/2] mm: restrict access to slab files under procfs and
 sysfs
Message-ID: <20110927191658.GB4820@albatros>
References: <20110927175453.GA3393@albatros>
 <alpine.DEB.2.00.1109271304470.11361@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1109271304470.11361@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Sep 27, 2011 at 13:08 -0500, Christoph Lameter wrote:
> Possible candidates:
> 
> christoph@oldy:~/n/linux-2.6$ grep proc_create mm/*
> mm/swapfile.c:	proc_create("swaps", 0, NULL, &proc_swaps_operations);
> mm/vmstat.c:	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
> mm/vmstat.c:	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
> mm/vmstat.c:	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
> mm/vmstat.c:	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
> 
> vmstat and zoneinfo in particular give similar information to what is
> revealed through the slab proc files.

Do you know whether these files are actively used?  I don't want to
break tools like "free" or "top".  In this case we'll have to discover
another way to limit this information.

Thank you!

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
