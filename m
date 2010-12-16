Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 85A9B6B00A8
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 20:05:41 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBG10Gp2028571
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Dec 2010 10:00:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E4E345DE5F
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 10:00:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F35345DE55
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 10:00:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E8BEE18006
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 10:00:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26CB31DB803E
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 10:00:16 +0900 (JST)
Date: Thu, 16 Dec 2010 09:54:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Transparent Hugepage Support #33
Message-Id: <20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101215051540.GP5638@random.random>
References: <20101215051540.GP5638@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Dec 2010 06:15:40 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> Some of some relevant user of the project:
> 
> KVM Virtualization
> GCC (kernel build included, requires a few liner patch to enable)
> JVM
> VMware Workstation
> HPC
> 
> It would be great if it could go in -mm.

Things should be done in memory cgroup is
 
 - make accounting correct (RSS count will be broken)
 - make move_charge() to work
   (at rmdir(), this is now broken. It seems move-charge-at-task-move to work)

Do you have known other viewpoints ? I'll look into when -mm is shipped.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
