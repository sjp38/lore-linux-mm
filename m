Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D61ED6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 20:20:17 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAJ1KFJq001907
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Nov 2010 10:20:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BB0FF45DE63
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:20:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8144645DE4F
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:20:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A5391DB8042
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:20:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DB9F7E08002
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:20:13 +0900 (JST)
Date: Fri, 19 Nov 2010 10:14:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 38 of 66] memcontrol: try charging huge pages from stock
Message-Id: <20101119101427.45d78929.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <9d26d3daf23632b20a7b.1288798093@v2.random>
References: <patchbomb.1288798055@v2.random>
	<9d26d3daf23632b20a7b.1288798093@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, 03 Nov 2010 16:28:13 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> The stock unit is just bytes, there is no reason to only take normal
> pages from it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

nonsense. The stock size is CHARGE_SIZE=32*PAGE_SIZE at maximum.
When we make this to be larger than HUGEPAGE size, 2M per cpu at least.
This means memcg's resource "usage" accounting will have 128MB inaccuracy.

Nack.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
