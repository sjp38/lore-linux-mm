Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 04FDD9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 16:03:15 -0400 (EDT)
Date: Tue, 27 Sep 2011 15:03:09 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
In-Reply-To: <20110927193810.GA5416@albatros>
Message-ID: <alpine.DEB.2.00.1109271459180.13797@router.home>
References: <20110927175453.GA3393@albatros> <20110927175642.GA3432@albatros> <20110927193810.GA5416@albatros>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, 27 Sep 2011, Vasiliy Kulikov wrote:

> On Tue, Sep 27, 2011 at 21:56 +0400, Vasiliy Kulikov wrote:
> > /proc/meminfo stores information related to memory pages usage, which
> > may be used to monitor the number of objects in specific caches (and/or
> > the changes of these numbers).  This might reveal private information
> > similar to /proc/slabinfo infoleaks.  To remove the infoleak, just
> > restrict meminfo to root.  If it is used by unprivileged daemons,
> > meminfo permissions can be altered the same way as slabinfo:
> >
> >     groupadd meminfo
> >     usermod -a -G meminfo $MONITOR_USER
> >     chmod g+r /proc/meminfo
> >     chgrp meminfo /proc/meminfo
>
> Just to make it clear: since this patch breaks "free", I don't propose
> it anymore.

Viewing free memory is usually necessary to check on reclaim activities
(things otherwise operating normally). "free" memory (in the sense of the
memory that an application can still allocate) is not really displayed by
free. Wish we had a new free that avoids all the misinterpretations.

Meminfo is also requires by vmstat.

If we want to go down this route then we need some sort of diagnostic
group that a user must be part of in order to allow viewing of basic
memory statistics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
