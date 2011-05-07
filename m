Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7A265900001
	for <linux-mm@kvack.org>; Sat,  7 May 2011 01:37:49 -0400 (EDT)
Date: Sat, 7 May 2011 01:37:29 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: mmotm 2011-05-06-16-39 uploaded (fs/proc/task_mmu)
Message-ID: <20110507053729.GA3205@fibrous.localdomain>
References: <201105070015.p470FlAR013200@imap1.linux-foundation.org> <20110506183517.29369143.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110506183517.29369143.rdunlap@xenotime.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: akpm@linux-foundation.org, Stephen Wilson <wilsons@start.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 06, 2011 at 06:35:17PM -0700, Randy Dunlap wrote:
> On Fri, 06 May 2011 16:39:31 -0700 akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2011-05-06-16-39 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> > 
> >    git://zen-kernel.org/kernel/mmotm.git
> > 
> > It contains the following patches against 2.6.39-rc6:
> 
> from "mm-proc-move-show_numa_map-to-fs-proc-task_mmuc.patch":
> 
> on i386 (X86_32):
> 
> fs/proc/task_mmu.c:981: error: implicit declaration of function 'mpol_to_str'
> 
> when CONFIG_SHMEM=n, CONFIG_TMPFS=n, and these NUMA config settings:

OK, thanks for finding this!  The key here is CONFIG_TMPFS=n.  I think
the only path forward is the obvious one.  If reasonable, the following
can be appied just prior to
mm-proc-move-show_numa_map-to-fs-proc-task_mmuc.patch.
