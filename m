Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D07F06B006E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 15:10:44 -0400 (EDT)
Date: Mon, 29 Oct 2012 15:10:42 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 06/16] tracepoint: use new hashtable implementation
Message-ID: <20121029191042.GA21864@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-6-git-send-email-levinsasha928@gmail.com> <20121029113515.GB9115@Krystal> <CA+1xoqce6uJ6wy3+2CBwsLHKnsz4wD0vt8MBEGKCFfXTvuC0Hg@mail.gmail.com> <20121029183157.GC3097@jtriplet-mobl1> <CA+1xoqfMrn9zDFMJNFfA0NA86wE_DedD97cP1yJ2UQdTjs3uyQ@mail.gmail.com> <20121029185319.GA21546@Krystal> <20121029185814.GC4066@htj.dyndns.org> <20121029190107.GD4066@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121029190107.GD4066@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Josh Triplett <josh@joshtriplett.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Tejun Heo (tj@kernel.org) wrote:
> On Mon, Oct 29, 2012 at 11:58:14AM -0700, Tejun Heo wrote:
> > On Mon, Oct 29, 2012 at 02:53:19PM -0400, Mathieu Desnoyers wrote:
> > > The argument about hash_init being useful to add magic values in the
> > > future only works for the cases where a hash table is declared with
> > > DECLARE_HASHTABLE(). It's completely pointless with DEFINE_HASHTABLE(),
> > > because we could initialize any debugging variables from within
> > > DEFINE_HASHTABLE().
> > 
> > You can do that with [0 .. HASH_SIZE - 1] initializer.
> 
> And in general, let's please try not to do optimizations which are
> pointless.  Just stick to the usual semantics.  You have an abstract
> data structure - invoke the initializer before using it.  Sure,
> optimize it if it shows up somewhere.  And here, if we do the
> initializers properly, it shouldn't cause any more actual overhead -
> ie. DEFINE_HASHTABLE() will basicallly boil down to all zero
> assignments and the compiler will put the whole thing in .bss anyway.

Yes, agreed. I was going too far in optimization land by proposing
assumptions on zeroed memory. All I actually really care about is that
we don't end up calling hash_init() on a statically defined (and thus
already initialized) hash table.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
