Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id EEB4C6B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 14:35:12 -0400 (EDT)
Date: Mon, 29 Oct 2012 14:35:10 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 15/16] openvswitch: use new hashtable implementation
Message-ID: <20121029183510.GA21114@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-15-git-send-email-levinsasha928@gmail.com> <20121029132931.GC16391@Krystal> <CA+1xoqfRGhPaBEVh228O5_295bWh8FmcyLSOwq8VE5Dm7i3JHg@mail.gmail.com> <20121029155957.GB18834@Krystal> <CA+1xoqcr5xmOkDfqL3P84CNdotOALOhiLRkJjsPCZzijSQUF6w@mail.gmail.com> <20121029181648.GB20796@Krystal> <20121029182209.GB4066@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121029182209.GB4066@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Tejun Heo (tj@kernel.org) wrote:
> Hello,
> 
> On Mon, Oct 29, 2012 at 02:16:48PM -0400, Mathieu Desnoyers wrote:
> > This is just one example in an attempt to show why different hash table
> > users may have different constraints: for a hash table entirely
> > populated by keys generated internally by the kernel, a random seed
> > might not be required, but for cases where values are fed by user-space
> > and from the NIC, I would argue that flexibility to implement a
> > randomizable hash function beats implementation simplicity any time.
> > 
> > And you could keep the basic use-case simple by providing hints to the
> > hash_32()/hash_64()/hash_ulong() helpers in comments.
> 
> If all you need is throwing in a salt value to avoid attacks, can't
> you just do that from caller side?  Scrambling the key before feeding
> it into hash_*() should work, no?

Yes, I think salting the "key" parameter would work.

Thanks,

Mathieu

> 
> Thanks.
> 
> -- 
> tejun

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
