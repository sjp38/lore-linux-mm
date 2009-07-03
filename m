Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DC9B66B004F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 19:55:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6303IWu024985
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 3 Jul 2009 09:03:20 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E267845DE63
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 09:03:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BCC9E45DE51
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 09:03:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A19961DB8041
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 09:03:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F0521DB8038
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 09:03:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] Show kernel stack usage to /proc/meminfo and OOM log
In-Reply-To: <4A4B9BA1.6040109@redhat.com>
References: <alpine.DEB.1.10.0907011315540.9522@gentwo.org> <4A4B9BA1.6040109@redhat.com>
Message-Id: <20090703090226.08E6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  3 Jul 2009 09:03:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

> Christoph Lameter wrote:
> > On Wed, 1 Jul 2009, David Howells wrote:
> > 
> >> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> >>
> >>> +	int pages = THREAD_SIZE / PAGE_SIZE;
> >> Bad assumption.  On FRV, for example, THREAD_SIZE is 8K and PAGE_SIZE is 16K.
> > 
> > Guess that means we need arch specific accounting for this counter.
> 
> Or we count the number of stacks internally and only
> convert to pages whenever we display the value.

Thanks good idea. I'll implement this today (or tommorow).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
