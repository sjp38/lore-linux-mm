Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 257468D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 03:51:37 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 566A13EE0C1
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:51:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B60945DE5B
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:51:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 10B6845DE56
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:51:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ED1111DB803B
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:51:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B1E7FE08004
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:51:32 +0900 (JST)
Date: Tue, 18 Jan 2011 17:45:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [LSF/MM TOPIC] memory control groups
Message-Id: <20110118174523.5c79a032.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTim_eDn-BS5OwmdowXMX75XgFWdcUepMJ5YBX1R7@mail.gmail.com>
References: <20110117191359.GI2212@cmpxchg.org>
	<AANLkTim_eDn-BS5OwmdowXMX75XgFWdcUepMJ5YBX1R7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 00:17:53 -0800
Michel Lespinasse <walken@google.com> wrote:


> > The per-memcg dirty accounting work e.g. allocates a bunch of new bits
> > in pc->flags and I'd like to hash out if this leaves enough room for
> > the structure packing I described, or whether we can come up with a
> > different way of tracking state.
> 
> This is probably longer term, but I would love to get rid of the
> duplication between global LRU and per-cgroup LRU. Global LRU could be
> approximated by scanning all per-cgroup LRU lists (in mounts
> proportional to the list lengths).
> 

I can't answer why the design, which memory cgroup's meta-page has its own LRU
rather than reusing page->lru, is selected at 1st implementation because I didn't
join the birth of memcg. Does anyone remember the reason or discussion ? 

As far as I can tell, I review patches for memcg with the viewpoint as
"Whether this patch will affect global LRU or not ? and will never break the
 algorithm of page reclaim of global LRU ?"

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
