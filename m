Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 339A96B006E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 15:17:37 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so9034029ied.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 12:17:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121029191256.GE4066@htj.dyndns.org>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-6-git-send-email-levinsasha928@gmail.com>
 <20121029113515.GB9115@Krystal> <CA+1xoqce6uJ6wy3+2CBwsLHKnsz4wD0vt8MBEGKCFfXTvuC0Hg@mail.gmail.com>
 <20121029183157.GC3097@jtriplet-mobl1> <CA+1xoqfMrn9zDFMJNFfA0NA86wE_DedD97cP1yJ2UQdTjs3uyQ@mail.gmail.com>
 <20121029185319.GA21546@Krystal> <CA+1xoqcSx04JEXy2aPu4Qt7Zb4iSqXBSjARgMae_FusgzpgnaQ@mail.gmail.com>
 <20121029191256.GE4066@htj.dyndns.org>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 29 Oct 2012 15:17:16 -0400
Message-ID: <CA+1xoqdi2pQENa=--FkPbOGOHgK+M26_jNCxGTkFiynqnR+7og@mail.gmail.com>
Subject: Re: [PATCH v7 06/16] tracepoint: use new hashtable implementation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Josh Triplett <josh@joshtriplett.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Mon, Oct 29, 2012 at 3:12 PM, Tejun Heo <tj@kernel.org> wrote:
> On Mon, Oct 29, 2012 at 03:09:36PM -0400, Sasha Levin wrote:
>> The other thing is whether hash_init() should be called for hashtables
>> that were created with DEFINE_HASHTABLE(). That point was raised by
>> Neil Brown last time this series went around, and it seems that no one
>> objected to the point that it should be consistent across the code.
>
> Hmmm?  If something is DEFINE_XXX()'d, you definitely shouldn't be
> calling XXX_init() on it.  That's how it is with most other abstract
> data types and you need *VERY* strong rationale to deviate from that.

Neil Brown raised that point last time that this series went around,
and suggested that this should be consistent and hash_init() would
appear everywhere, even if DEFINE_HASHTABLE() was used. Since no one
objected to that I thought we're going with that.

I'll chalk it up to me getting confused :)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
