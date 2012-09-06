Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id CC6076B0070
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 12:50:57 -0400 (EDT)
Date: Thu, 6 Sep 2012 12:50:55 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
	hashtable
Message-ID: <20120906165055.GC7385@Krystal>
References: <20120828230050.GA3337@Krystal> <1346772948.27919.9.camel@gandalf.local.home> <50462C99.5000007@redhat.com> <50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal> <5048AAF6.5090101@gmail.com> <20120906145545.GA17332@leaf> <5048C615.4070204@gmail.com> <1346947206.1680.36.camel@gandalf.local.home> <5048CDA2.10300@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5048CDA2.10300@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Josh Triplett <josh@joshtriplett.org>, Pedro Alves <palves@redhat.com>, Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> On 09/06/2012 06:00 PM, Steven Rostedt wrote:
> >> > I think that that code doesn't make sense. The users of hlist_for_each_* aren't
> >> > supposed to be changing the loop cursor.
> > I totally agree. Modifying the 'node' pointer is just asking for issues.
> > Yes that is error prone, but not due to the double loop. It's due to the
> > modifying of the node pointer that is used internally by the loop
> > counter. Don't do that :-)
> 
> While we're on this subject, I haven't actually seen hlist_for_each_entry() code
> that even *touches* 'pos'.
> 
> Will people yell at me loudly if I change the prototype of those macros to be:
> 
> 	hlist_for_each_entry(tpos, head, member)
> 
> (Dropping the 'pos' parameter), and updating anything that calls those macros to
> drop it as well?

I think the intent there is to keep hlist macros and list macros
slightly in sync. Given those are vastly used, I'm not sure you want to
touch them. But hey, that's just my 2 cents.

Thanks,

Mathieu

> 
> 
> Thanks,
> Sasha

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
