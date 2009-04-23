Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 00B4E6B0111
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 20:26:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3N0RHTs026652
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 23 Apr 2009 09:27:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3DBD45DD87
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:27:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BCA4045DD7B
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:27:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A15D1E08003
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:27:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4453F1DB8041
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:27:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 18/22] Use allocation flags as an index to the zone watermark
In-Reply-To: <1240422423.10627.96.camel@nimitz>
References: <20090422171451.GG15367@csn.ul.ie> <1240422423.10627.96.camel@nimitz>
Message-Id: <20090423092350.F6E6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 23 Apr 2009 09:27:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 2009-04-22 at 18:14 +0100, Mel Gorman wrote:
> > Preference of taste really. When I started a conversion to accessors, it
> > changed something recognised to something new that looked uglier to me.
> > Only one place cares about the union enough to access is via an array so
> > why spread it everywhere.
> 
> Personally, I'd say for consistency.  Someone looking at both forms
> wouldn't necessarily know that they refer to the same variables unless
> they know about the union.

for just clalification...

AFAIK, C language specification don't gurantee point same value.
compiler can insert pad between struct-member and member, but not insert
into array.

However, all gcc version don't do that. I think. but perhaps I missed
some minor gcc release..


So, I also like Dave's idea. but it only personal feeling.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
