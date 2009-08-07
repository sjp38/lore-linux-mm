Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CF64A6B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 23:11:11 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n773BC9q026044
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 7 Aug 2009 12:11:12 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 198422AEA83
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 12:11:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DAA3445DE4F
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 12:11:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A64C31DB805E
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 12:11:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 135A91DB803C
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 12:11:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
In-Reply-To: <4A7AD6EB.9090208@redhat.com>
References: <4A7AC201.4010202@redhat.com> <4A7AD6EB.9090208@redhat.com>
Message-Id: <20090807120857.5BE2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri,  7 Aug 2009 12:11:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Avi Kivity <avi@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

(cc to memcg folks)

> Avi Kivity wrote:
> > On 08/06/2009 01:59 PM, Wu Fengguang wrote:
> 
> >> As a refinement, the static variable 'recent_all_referenced' could be
> >> moved to struct zone or made a per-cpu variable.
> > 
> > Definitely this should be made part of the zone structure, consider the 
> > original report where the problem occurs in a 128MB zone (where we can 
> > expect many pages to have their referenced bit set).
> 
> The problem did not occur in a 128MB zone, but in a 128MB cgroup.
> 
> Putting it in the zone means that the cgroup, which may have
> different behaviour from the rest of the zone, due to excessive
> memory pressure inside the cgroup, does not get the right
> statistics.

maybe, I heven't catch your point.

Current memcgroup logic also use recent_scan/recent_rotate statistics.
Isn't it enought?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
