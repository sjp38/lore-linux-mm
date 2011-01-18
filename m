Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 505F48D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 03:53:49 -0500 (EST)
Date: Tue, 18 Jan 2011 03:53:40 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1805847943.28168.1295340820009.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110117191359.GI2212@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] memory control groups
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> Hello,
> 
> on the MM summit, I would like to talk about the current state of
> memory control groups, the features and extensions that are currently
> being developed for it, and what their status is.
> 
> I am especially interested in talking about the current runtime memory
> overhead memcg comes with (1% of ram) and what we can do to shrink it.
> 
> In comparison to how efficiently struct page is packed, and given that
> distro kernels come with memcg enabled per default, I think we should
> put a bit more thought into how struct page_cgroup (which exists for
> every page in the system as well) is organized.
> 
> I have a patch series that removes the page backpointer from struct
> page_cgroup by storing a node ID (or section ID, depending on whether
> sparsemem is configured) in the free bits of pc->flags.
> 
> I also plan on replacing the pc->mem_cgroup pointer with an ID
> (KAMEZAWA-san has patches for that), and move it to pc->flags too.
> Every flag not used means doubling the amount of possible control
> groups, so I have patches that get rid of some flags currently
> allocated, including PCG_CACHE, PCG_ACCT_LRU, and PCG_MIGRATION.
> 
> [ I meant to send those out much earlier already, but a bug in the
> migration rework was not responding to my yelling 'Marco', and now my
> changes collide horribly with THP, so it will take another rebase. ]
> 
> The per-memcg dirty accounting work e.g. allocates a bunch of new bits
> in pc->flags and I'd like to hash out if this leaves enough room for
> the structure packing I described, or whether we can come up with a
> different way of tracking state.
> 
> Would other people be interested in discussing this?
I would love to be present the testing we have done here in work, and 
to gather some ideas from the testing angle as a QE engineer if there is
an invitation for me to obtain visa/travel budget etc.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
