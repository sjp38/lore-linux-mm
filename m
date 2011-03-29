Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1476D8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:31:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 162B13EE0C0
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:31:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EED7E45DE76
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:31:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA5EF45DE92
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:31:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD128E18001
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:31:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 797EBE08002
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:31:11 +0900 (JST)
Date: Tue, 29 Mar 2011 10:24:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] memcg: update documentation to describe
 usage_in_bytes
Message-Id: <20110329102445.a46760ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110329101511.d30f3518.nishimura@mxp.nes.nec.co.jp>
References: <20110321102420.GB26047@tiehlicka.suse.cz>
	<20110322091014.27677ab3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110322104723.fd81dddc.nishimura@mxp.nes.nec.co.jp>
	<20110322073150.GA12940@tiehlicka.suse.cz>
	<20110323092708.021d555d.nishimura@mxp.nes.nec.co.jp>
	<20110323133517.de33d624.kamezawa.hiroyu@jp.fujitsu.com>
	<20110328085508.c236e929.nishimura@mxp.nes.nec.co.jp>
	<20110328132550.08be4389.nishimura@mxp.nes.nec.co.jp>
	<20110328074341.GA5693@tiehlicka.suse.cz>
	<20110328181127.b8a2a1c5.kamezawa.hiroyu@jp.fujitsu.com>
	<20110328094820.GC5693@tiehlicka.suse.cz>
	<20110328193108.07965b4a.kamezawa.hiroyu@jp.fujitsu.com>
	<20110329101511.d30f3518.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 29 Mar 2011 10:15:11 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Since 569b846d(memcg: coalesce uncharge during unmap/truncate), we do batched
> (delayed) uncharge at truncation/unmap. And since cdec2e42(memcg: coalesce
> charging via percpu storage), we have percpu cache for res_counter.
> 
> These changes improved performance of memory cgroup very much, but made
> res_counter->usage usually have a bigger value than the actual value of memory usage.
> So, *.usage_in_bytes, which show res_counter->usage, are not desirable for precise
> values of memory(and swap) usage anymore.
> 
> Instead of removing these files completely(because we cannot know res_counter->usage
> without them), this patch updates the meaning of those files.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
