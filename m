Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6CE6B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 22:22:25 -0400 (EDT)
Date: Thu, 19 May 2011 11:16:19 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem
 fix
Message-Id: <20110519111619.1cd881ee.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <alpine.LSU.2.00.1105181102050.4087@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
	<20110518144349.a44ae926.nishimura@mxp.nes.nec.co.jp>
	<alpine.LSU.2.00.1105181102050.4087@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Wed, 18 May 2011 11:25:48 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Wed, 18 May 2011, Daisuke Nishimura wrote:
> > On Tue, 17 May 2011 11:24:40 -0700 (PDT)
> > Hugh Dickins <hughd@google.com> wrote:
> > 
> > > mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> > > target mm, not for current mm (but of course they're usually the same).
> > > 
> > hmm, why ?
> > In shmem_getpage(), we charge the page to the memcg where current mm belongs to,
> 
> (In the case when it's this fault which is creating the page.
> Just as when filemap_fault() reads in the page, add_to_page_cache
> will charge it to the current->mm's memcg, yes.  Arguably correct.)
> 
> > so I think counting vm events of the memcg is right.
> 
> It should be consistent with which task gets the maj_flt++, and
> it should be consistent with filemap_fault(), and it should be a
> subset of what's counted by mem_cgroup_count_vm_event(mm, PGFAULT).
> 
> In each case, those work on target mm rather than current->mm.
> 
Thank you for your explanation. I can agree that we should count PGMAJFLT of memcg
where the target mm belongs to.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
