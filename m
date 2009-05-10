Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 20EE46B00A9
	for <linux-mm@kvack.org>; Sun, 10 May 2009 10:46:50 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [RFC][PATCH 0/6] PM/Hibernate: Rework memory shrinking (rev. 3)
Date: Sun, 10 May 2009 15:48:56 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905072348.59856.rjw@sisk.pl>
In-Reply-To: <200905072348.59856.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905101548.57557.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 07 May 2009, Rafael J. Wysocki wrote:
> On Thursday 07 May 2009, Rafael J. Wysocki wrote:
> > Hi,
> > 
> > The following patchset is an attempt to rework the memory shrinking mechanism
> > used during hibernation to make room for the image.  It is a work in progress
> > and most likely it's going to be modified, but it has been discussed recently
> > and I'd like to get comments on the current version.
> > 
> > [1/5] - disable the OOM kernel after freezing tasks (this will be dropped if
> >         it's verified that we can avoid the OOM killing by using
> >         __GFP_FS|__GFP_WAIT|__GFP_NORETRY|__GFP_NOWARN
> >         in the next patches).
> > 
> > [2/5] - drop memory shrinking from the suspend (to RAM) code path
> > 
> > [3/5] - move swsusp_shrink_memory() to snapshot.c
> > 
> > [4/5] - rework swsusp_shrink_memory() (to use memory allocations for applying
> >         memory pressure)
> > 
> > [5/5] - allocate image pages along with the shrinking.
> 
> Updated patchset follows.

I the meantime I added a patch that attempts to computer the size of the hard
core working set.  I also had to rework the patch reworking
swsusp_shrink_memory() so that it takes highmem into account.

Currently, the patchset consists of the following patches:

[1/6] - disable the OOM kernel after freezing tasks (this will be dropped if
        it's verified that we can avoid the OOM killing by using
        __GFP_FS|__GFP_WAIT|__GFP_NORETRY|__GFP_NOWARN
        in the next patches).

[2/6] - drop memory shrinking from the suspend (to RAM) code path

[3/6] - move swsusp_shrink_memory() to snapshot.c

[4/6] - rework swsusp_shrink_memory() (to use memory allocations for applying
        memory pressure)

[5/6] - allocate image pages along with the shrinking

[6/6] - estimate the size of the hard core working set and use it as the lower
        limit of the image size.

Comments welcome.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
