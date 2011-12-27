Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2F4F46B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 04:17:22 -0500 (EST)
Date: Tue, 27 Dec 2011 10:17:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Announcement - memcg-devel git tree
Message-ID: <20111227091717.GA8537@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Hi,
let me announce memcg-devel git tree which is currently hosted at
github (https://github.com/mstsxfx/memcg-devel). The tree is based on
Linus' tree and it contains most of the memcg patches (apart from the last
that went into mmotm - which will get there shortly).
For a short summary we currently have:
Andrew Morton (2):
      mm-vmscan-distinguish-between-memcg-triggering-reclaim-and-memcg-being-scanned-checkpatch-fixes
      memcg-make-mem_cgroup_split_huge_fixup-more-efficient-fix

Hugh Dickins (1):
      mm: memcg: remove unused node/section info from pc->flags fix

Johannes Weiner (18):
      mm: memcg: consolidate hierarchy iteration primitives
      mm: vmscan: distinguish global reclaim from global LRU scanning
      mm: vmscan: distinguish between memcg triggering reclaim and memcg being scanned
      mm: memcg: per-priority per-zone hierarchy scan generations
      mm: move memcg hierarchy reclaim to generic reclaim code
      mm: memcg: remove optimization of keeping the root_mem_cgroup LRU lists empty
      mm: vmscan: convert global reclaim to per-memcg LRU lists
      mm: collect LRU list heads into struct lruvec
      mm: make per-memcg LRU lists exclusive
      mm: memcg: remove unused node/section info from pc->flags
      mm: memcg: shorten preempt-disabled section around event checks
      mm: oom_kill: remove memcg argument from oom_kill_task()
      mm: unify remaining mem_cont, mem, etc. variable names to memcg
      mm: memcg: clean up fault accounting
      mm: memcg: lookup_page_cgroup (almost) never returns NULL
      mm: page_cgroup: check page_cgroup arrays in lookup_page_cgroup() only when necessary
      mm: memcg: remove unneeded checks from newpage_charge()
      mm: memcg: remove unneeded checks from uncharge_page()

KAMEZAWA Hiroyuki (2):
      memcg: make mem_cgroup_split_huge_fixup() more efficient
      memcg: add mem_cgroup_replace_page_cache() to fix LRU issue

* What is the tree good for?
Well, after Andrew discontinued his mmotm tree it became much harder to
develop memcg patches. linux-next is a moving target so it is not the
right choice if somebody wants to develop patches and keep them in shape
for a longer time.
We have discussed that with Johannes and he came with an idea that we
could maintain memcg specific git tree. So here it is ;)
The tree is not aimed for Linus or Andrew to pull from. It is only for
memcg developers to have a common ground.

* How is the tree organized?
We have a master branch which tracks linus and we will have `since-XYZ'
branches which will contain all acked patches on top of the XYZ linus
release. Johannes found the name since-XYZ little bit confusing becaue
tags usually refer to future release but my argument was that it should
be clear on what we are based rather than a target where the patches go
as we do not know that release.
But I am open to changes, of course.

* What is the workflow?
Master branch will be updated whenever Linus releases a new version or
when some of the memcg patch depends on generic mm code.
since-XYZ will be updated when the patch either gets accepted by Andrew
or it gets ack from all (most) of maintainers.
If a patch depends on a generic mm code we will just merge the
respective commit into the branch and apply the memcg patch on top of
it.
When Linus releases a new kernel version we will create a new since-XYZ
branch and rebase the previous (size-XYZ-1) on top of it. If some of the
patches were accepted git rebase will recognize that and drop them.
This means that git log master..since-XYZ will always lists patches that
are not merged yet.

* Who will maintain the tree?
Currently it is me and Johannes.

# For read only access - aka developer
$ git remote add github-memcg git://github.com/mstsxfx/memcg-devel.git
$ git fetch github-memcg
$ git branch mydevel github-memcg/since-XYZ

I hope this help you.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
