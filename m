Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 0427F6B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 16:33:40 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so4479143pbb.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 13:33:40 -0700 (PDT)
Date: Fri, 24 Aug 2012 13:33:32 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
 hashtable
Message-ID: <20120824203332.GF21325@google.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
 <1345602432-27673-2-git-send-email-levinsasha928@gmail.com>
 <20120822180138.GA19212@google.com>
 <50357840.5020201@gmail.com>
 <20120823200456.GD14962@google.com>
 <5037DA47.9010306@gmail.com>
 <20120824195941.GC21325@google.com>
 <5037E00B.6090606@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5037E00B.6090606@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

Hello, Sasha.

On Fri, Aug 24, 2012 at 10:11:55PM +0200, Sasha Levin wrote:
> > If this implementation is about the common trivial case, why not just
> > have the usual DECLARE/DEFINE_HASHTABLE() combination?
> 
> When we add the dynamic non-resizable support, how would DEFINE_HASHTABLE() look?

Hmmm?  DECLARE/DEFINE are usually for static ones.

> > I don't know.  If we stick to the static (or even !resize dymaic)
> > straight-forward hash - and we need something like that - I don't see
> > what the full encapsulation buys us other than a lot of trivial
> > wrappers.
> 
> Which macros do you consider as trivial within the current API?
> 
> Basically this entire thing could be reduced to DEFINE/DECLARE_HASHTABLE and
> get_bucket(), but it would make the life of anyone who wants a slightly
> different hashtable a hell.

Wouldn't the following be enough to get most of the benefits?

* DECLARE/DEFINE
* hash_head()
* hash_for_each_head()
* hash_add*()
* hash_for_each_possible*()

> I think that right now the only real trivial wrapper is hash_hashed(), and I
> think it's a price worth paying to have a single hashtable API instead of
> fragmenting it when more implementations come along.

I'm not objecting strongly against full encapsulation but having this
many thin wrappers makes me scratch my head.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
