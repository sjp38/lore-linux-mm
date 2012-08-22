Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 597E86B0070
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 14:05:06 -0400 (EDT)
Received: by dadi14 with SMTP id i14so1116420dad.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:05:05 -0700 (PDT)
Date: Wed, 22 Aug 2012 11:05:00 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/17] workqueue: use new hashtable implementation
Message-ID: <20120822180500.GB19212@google.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
 <1345602432-27673-5-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345602432-27673-5-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Wed, Aug 22, 2012 at 04:26:59AM +0200, Sasha Levin wrote:
> Switch workqueues to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in the workqueues.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
