Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 2F42E6B0044
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 14:59:11 -0500 (EST)
Received: by iajr24 with SMTP id r24so3636631iaj.14
        for <linux-mm@kvack.org>; Fri, 09 Mar 2012 11:59:09 -0800 (PST)
Date: Fri, 9 Mar 2012 11:58:34 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3.3] memcg: free mem_cgroup by RCU to fix oops
In-Reply-To: <alpine.LSU.2.00.1203072155140.11048@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1203091138260.19300@eggly.anvils>
References: <alpine.LSU.2.00.1203072155140.11048@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Tejun Heo <tj@kernel.org>, Ying Han <yinghan@google.com>, Stanislaw Gruszka <sgruszka@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 Mar 2012, Hugh Dickins wrote:
> 
> I'm posting this a little prematurely to get eyes on it, since it's
> more than a two-liner, but 3.3 time is running out.  If it is what's
> needed to fix my oopses, I won't really be sure before Friday morning.
> What's running now on the machine affected is using kfree_rcu(), but I
> did hack it earlier to check that the vfree_rcu() alternative works.

Yes, please do send that patch on to Linus for 3.3.

It did not get as much as the 36 hours of testing I had hoped for, only
25 hours so far.  12 hours while I was out yesterday got wasted by a
wireless driver interrupt spewing approximately one million messages:

iwl3945 0000:08:00.0: MAC is in deep sleep!. CSR_GP_CNTRL = 0xFFFFFFFF

which I've not suffered from before, and hope not again.  Having kdb
in, I did take a look what was going on with the memcg load when it was
interrupted: it appeared to be normal, and I've no reason to suppose that
my kfree_rcu() was in any way responsible for the wireless aberration.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
