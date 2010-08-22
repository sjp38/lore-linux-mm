Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B7D9600044
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 06:28:01 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7MARwlI008063
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 22 Aug 2010 19:27:59 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 99A5145DE4F
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 19:27:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 69FBC45DE4E
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 19:27:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EE1E1DB8015
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 19:27:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BDB31DB8012
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 19:27:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in /proc/vmstat
In-Reply-To: <20100820190603.6003.A69D9226@jp.fujitsu.com>
References: <1282296689-25618-5-git-send-email-mrubin@google.com> <20100820190603.6003.A69D9226@jp.fujitsu.com>
Message-Id: <20100822192710.6018.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 22 Aug 2010 19:27:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michael Rubin <mrubin@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

> > The kernel already exposes the user desired thresholds in /proc/sys/vm
> > with dirty_background_ratio and background_ratio. But the kernel may
> > alter the number requested without giving the user any indication that
> > is the case.
> > 
> > Knowing the actual ratios the kernel is honoring can help app developers
> > understand how their buffered IO will be sent to the disk.
> > 
> > 	$ grep threshold /proc/vmstat
> > 	nr_dirty_threshold 409111
> > 	nr_dirty_background_threshold 818223
> > 
> > Signed-off-by: Michael Rubin <mrubin@google.com>
> 
> Looks good to me.
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

sorry, this is mistake. Wu pointed out this patch is unnecessary.


Wu wrote: 
> I realized that the dirty thresholds has already been exported here:
> 
> $ grep Thresh  /debug/bdi/8:0/stats
> BdiDirtyThresh:     381000 kB
> DirtyThresh:       1719076 kB
> BackgroundThresh:   859536 kB
> 
> So why not use that interface directly?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
