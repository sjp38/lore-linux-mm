Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 502E96B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 19:07:46 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so4655252pbb.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 16:07:45 -0700 (PDT)
Date: Fri, 24 Aug 2012 16:07:40 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
 hashtable
Message-ID: <20120824230740.GN21325@google.com>
References: <20120822180138.GA19212@google.com>
 <50357840.5020201@gmail.com>
 <20120823200456.GD14962@google.com>
 <5037DA47.9010306@gmail.com>
 <20120824195941.GC21325@google.com>
 <5037E00B.6090606@gmail.com>
 <20120824203332.GF21325@google.com>
 <5037E9D9.9000605@gmail.com>
 <20120824212348.GK21325@google.com>
 <5038074D.300@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5038074D.300@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

Hello,

On Sat, Aug 25, 2012 at 12:59:25AM +0200, Sasha Levin wrote:
> Thats the thing, the amount of things of things you can do with a given bucket
> is very limited. You can't add entries to any point besides the head (without
> walking the entire list).

Kinda my point.  We already have all the hlist*() interface to deal
with such cases.  Having something which is evidently the trivial
hlist hashtable and advertises as such in the interface can be
helpful.  I think we need that more than we need anything fancy.

Heh, this is a debate about which one is less insignificant.  I can
see your point.  I'd really like to hear what others think on this.

Guys, do we want something which is evidently trivial hlist hashtable
which can use hlist_*() API directly or do we want something better
encapsulated?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
