Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 522736B005A
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 12:18:15 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3849566pad.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:18:14 -0700 (PDT)
Date: Mon, 29 Oct 2012 09:18:09 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v7 01/16] hashtable: introduce a small and naive hashtable
Message-ID: <20121029161809.GA4066@htj.dyndns.org>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <20121029112907.GA9115@Krystal>
 <CA+1xoqfQn92igbFS1TtrpYuSiy7+Ro02ar=axgqSOJOuE_EVuA@mail.gmail.com>
 <20121029161412.GB18944@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121029161412.GB18944@Krystal>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

Hello,

On Mon, Oct 29, 2012 at 12:14:12PM -0400, Mathieu Desnoyers wrote:
> Most of the calls to this initialization function apply it on zeroed
> memory (static/kzalloc'd...), which makes it useless. I'd actually be in
> favor of removing those redundant calls (as I pointed out in another
> email), and document that zeroed memory don't need to be explicitly
> initialized.
> 
> Those sites that need to really reinitialize memory, or initialize it
> (if located on the stack or in non-zeroed dynamically allocated memory)
> could use a memset to 0, which will likely be faster than setting to
> NULL on many architectures.

I don't think it's a good idea to optimize out the basic encapsulation
there.  We're talking about re-zeroing some static memory areas which
are pretty small.  It's just not worth optimizing out at the cost of
proper initializtion.  e.g. We might add debug fields to list_head
later.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
