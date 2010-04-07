Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2523E6B01F2
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 21:23:11 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o371N7uB003113
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 7 Apr 2010 10:23:07 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C46645DE4F
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 10:23:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C90145DE51
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 10:23:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EBB121DB8040
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 10:23:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BB7A1DB805B
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 10:23:03 +0900 (JST)
Date: Wed, 7 Apr 2010 10:19:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 10/14] Add /sys trigger for per-node memory compaction
Message-Id: <20100407101913.58d1855b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100406175601.b131e9d2.akpm@linux-foundation.org>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
	<1270224168-14775-11-git-send-email-mel@csn.ul.ie>
	<20100406170559.52093bd5.akpm@linux-foundation.org>
	<20100407093148.d5d1c42f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100406175601.b131e9d2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 2010 17:56:01 -0400
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 7 Apr 2010 09:31:48 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > A cgroup which controls placement of memory is cpuset.
> 
> err, yes, that.
> 
> > One idea is per cpuset. But per-node seems ok.
> 
> Which is superior?
> 
> Which maps best onto the way systems are used (and onto ways in which
> we _intend_ that systems be used)?
> 

node has hugepage interface now.

[root@bluextal qemu-kvm-0.12.3]# ls /sys/devices/system/node/node0/hugepages/
hugepages-2048kB

So, per-node knob is straightforward. 

> Is the physical node really the best unit-of-administration?  And is
> direct access to physical nodes the best means by which admins will
> manage things?

In these days, we tend to use "setup tool" for using cpuset, etc.
(as libcgroup.)

Considering control by userland-support-soft, I think pernode is not bad.
And per-cpuset requires users to mount cpuset.
(Now, most of my customer doesn't use cpuset.)


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
