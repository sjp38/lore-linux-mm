Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3F9296B00F7
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 13:14:38 -0400 (EDT)
Date: Mon, 18 Jul 2011 10:14:35 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [Patch] mm: make CONFIG_NUMA depend on CONFIG_SYSFS
Message-Id: <20110718101435.14c38ae7.rdunlap@xenotime.net>
In-Reply-To: <20110718170950.GD8006@one.firstfloor.org>
References: <1310987909-3129-1-git-send-email-amwang@redhat.com>
	<CAOJsxLHuqvVEKg84jmRW_yfLic9ytB8GzeAE4YWauxSWryHGzA@mail.gmail.com>
	<20110718170950.GD8006@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@kernel.org>, Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon, 18 Jul 2011 19:09:50 +0200 Andi Kleen wrote:

> On Mon, Jul 18, 2011 at 03:14:18PM +0300, Pekka Enberg wrote:
> > On Mon, Jul 18, 2011 at 2:18 PM, Amerigo Wang <amwang@redhat.com> wrote:
> > > On ppc, we got this build error with randconfig:
> > >
> > > drivers/built-in.o:(.toc1+0xf90): undefined reference to `vmstat_text': 1 errors in 1 logs
> > >
> > > This is due to that it enabled CONFIG_NUMA but not CONFIG_SYSFS.
> > >
> > > And the user-space tool numactl depends on sysfs files too.
> > > So, I think it is very reasonable to make CONFIG_NUMA depend on CONFIG_SYSFS.
> > 
> > Is it? CONFIG_NUMA is useful even without userspace numactl tool, no?
> 
> Yes it is. No direct dependency.
> 
> I would rather fix it in ppc.

This isn't a ppc-only error.  It happens when CONFIG_PROC_FS is not enabled
(or is it CONFIG_SYSFS?).

I reported it for linux-next of 20110526:

when CONFIG_PROC_FS is not enabled:

drivers/built-in.o: In function `node_read_vmstat':
node.c:(.text+0x56ffa): undefined reference to `vmstat_text'


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
