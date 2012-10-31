Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 79CD96B008C
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 21:15:50 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so1674260ied.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 18:15:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121031005128.GA30251@umich.edu>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org> <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
 <20121031005128.GA30251@umich.edu>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Tue, 30 Oct 2012 21:15:29 -0400
Message-ID: <CA+1xoqd9CMP4_CET38LTm6vVXwbButn3hJNbcFs6Darkh1EJSg@mail.gmail.com>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Rees <rees@umich.edu>
Cc: Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Tue, Oct 30, 2012 at 8:51 PM, Jim Rees <rees@umich.edu> wrote:
> Sasha Levin wrote:
>
>   On Tue, Oct 30, 2012 at 5:42 PM, Tejun Heo <tj@kernel.org> wrote:
>   > Hello,
>   >
>   > Just some nitpicks.
>   >
>   > On Tue, Oct 30, 2012 at 02:45:57PM -0400, Sasha Levin wrote:
>   >> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
>   >> +#define hash_min(val, bits)                                                  \
>   >> +({                                                                           \
>   >> +     sizeof(val) <= 4 ?                                                      \
>   >> +     hash_32(val, bits) :                                                    \
>   >> +     hash_long(val, bits);                                                   \
>   >> +})
>   >
>   > Doesn't the above fit in 80 column.  Why is it broken into multiple
>   > lines?  Also, you probably want () around at least @val.  In general,
>   > it's a good idea to add () around any macro argument to avoid nasty
>   > surprises.
>
>   It was broken to multiple lines because it looks nicer that way (IMO).
>
>   If we wrap it with () it's going to go over 80, so it's going to stay
>   broken down either way :)
>
> I would prefer the body be all on one line too. But shouldn't this be a
> static inline function?

We want sizeof(val), which wouldn't work in a static inline. We can
either wrap a static inline __hash_min() with a macro and pass that
size to it, but that's quite an overkill here, or we can add a size
parameter to hash_min(), but it would look awkward considering how
hash_32()/hash_64()/hash_long() look like.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
