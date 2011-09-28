Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA4579000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:46:19 -0400 (EDT)
Received: by pzk4 with SMTP id 4so23053135pzk.6
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 14:46:17 -0700 (PDT)
Date: Wed, 28 Sep 2011 14:46:14 -0700
From: Andrew Morton <akpm00@gmail.com>
Subject: Re: [PATCH 2/2] mm: restrict access to /proc/meminfo
Message-Id: <20110928144614.38591e97.akpm00@gmail.com>
In-Reply-To: <20110927193810.GA5416@albatros>
References: <20110927175453.GA3393@albatros>
	<20110927175642.GA3432@albatros>
	<20110927193810.GA5416@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Kees Cook <kees@ubuntu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Valdis.Kletnieks@vt.edu, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 27 Sep 2011 23:38:10 +0400
Vasiliy Kulikov <segoon@openwall.com> wrote:

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

It will break top(1) too.  It isn't my favoritest-ever patch :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
