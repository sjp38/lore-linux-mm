Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C6516B004D
	for <linux-mm@kvack.org>; Thu, 14 May 2009 19:27:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4ENS8aK030145
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 15 May 2009 08:28:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C56045DE53
	for <linux-mm@kvack.org>; Fri, 15 May 2009 08:28:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E456845DE51
	for <linux-mm@kvack.org>; Fri, 15 May 2009 08:28:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 39A2B1DB803A
	for <linux-mm@kvack.org>; Fri, 15 May 2009 08:28:07 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EC8491DB803F
	for <linux-mm@kvack.org>; Fri, 15 May 2009 08:28:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped pages from reclaim
In-Reply-To: <alpine.DEB.1.10.0905141612100.15881@qirst.com>
References: <20090513084306.5874.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905141612100.15881@qirst.com>
Message-Id: <20090515082312.F5B6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 15 May 2009 08:28:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Wed, 13 May 2009, KOSAKI Motohiro wrote:
> 
> > > All these expiration modifications do not take into account that a desktop
> > > may sit idle for hours while some other things run in the background (like
> > > backups at night or updatedb and other maintenance things). This still
> > > means that the desktop will be usuable in the morning.
> >
> > Have you seen this phenomenom?
> > I always use linux desktop for development. but I haven't seen it.
> > perhaps I have no luck. I really want to know reproduce way.
> >
> > Please let me know reproduce way.
> 
> Run a backup (or rsync) over a few hundred GB.

-ENOTREPRODUCED

umm.
May I ask detail operation?


> > > The percentage of file backed pages protected is set via
> > > /proc/sys/vm/file_mapped_ratio. This defaults to 20%.
> >
> > Why do you think typical mapped ratio is less than 20% on desktop machine?
> 
> Observation of the typical mapped size of Firefox under KDE.

My point is, desktop people have very various mapped ratio.
Do you oppose this?


> > key point is access-once vs access-many.
> 
> Nothing against it if it works.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
