Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 7A2896B006C
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 21:29:33 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so4249463pbb.14
        for <linux-mm@kvack.org>; Sun, 28 Oct 2012 18:29:32 -0700 (PDT)
Date: Sun, 28 Oct 2012 18:29:27 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v7 08/16] block,elevator: use new hashtable implementation
Message-ID: <20121029012927.GA5171@htj.dyndns.org>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-8-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351450948-15618-8-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Sun, Oct 28, 2012 at 03:02:20PM -0400, Sasha Levin wrote:
> Switch elevator to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in the elevator.
> 
> This also removes the dymanic allocation of the hash table. The size of the table is
> constant so there's no point in paying the price of an extra dereference when accessing
> it.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Reviewed-by: Tejun Heo <tj@kernel.orG>

But please reformat commit message to fit inside 80col (preferably 74
or something like that).

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
