Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0F79A6B0088
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 10:19:16 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1149880Ab0L2PTD (ORCPT <rfc822;linux-mm@kvack.org>);
	Wed, 29 Dec 2010 16:19:03 +0100
Date: Wed, 29 Dec 2010 16:19:03 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH 2/3] drivers/xen/balloon.c: Various balloon features and fixes
Message-ID: <20101229151903.GB2743@router-fw-old.local.net-space.pl>
References: <20101220134724.GC6749@router-fw-old.local.net-space.pl> <20101227150847.GA3728@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101227150847.GA3728@dumpdata.com>
Sender: owner-linux-mm@kvack.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Dec 27, 2010 at 10:08:47AM -0500, Konrad Rzeszutek Wilk wrote:
> On Mon, Dec 20, 2010 at 02:47:24PM +0100, Daniel Kiper wrote:
> > +
> > +		/*
> > +		 * state > 0: hungry,
> > +		 * state == 0: done or nothing to do,
> > +		 * state < 0: error, go to sleep.
>
> Would it be better to just have #defines for this?

Changed to enum. I will send new patch release today.

> > +	balloon_stats.schedule_delay = 1;
> > +	balloon_stats.max_schedule_delay = 32;
>
> How did you arrive at that number?

This is in seconds. Initial delay is 1 s.
It could not be greater than 32 s.
I think that those values are good for
default config because they provide good
resposivnes of balloon process and protect
before CPU exhaust by it during erros.
However, if those values are not acceptable
by user he/she could change them using sysfs.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
