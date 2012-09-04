Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 2CC586B0085
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:27:11 -0400 (EDT)
Message-ID: <1346801227.27919.40.camel@gandalf.local.home>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
 hashtable
From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 04 Sep 2012 19:27:07 -0400
In-Reply-To: <50468778.5000207@redhat.com>
References: <20120824203332.GF21325@google.com> <5037E9D9.9000605@gmail.com>
	     <20120824212348.GK21325@google.com> <5038074D.300@gmail.com>
	     <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal>
	     <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>
	     <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>
	     <20120828230050.GA3337@Krystal>
	    <1346772948.27919.9.camel@gandalf.local.home>
	   <50462C99.5000007@redhat.com>  <50462EE8.1090903@redhat.com>
	   <1346779027.27919.15.camel@gandalf.local.home>
	   <50463883.8080706@redhat.com>
	  <1346792345.27919.18.camel@gandalf.local.home>
	  <504677C8.3050801@redhat.com>
	 <1346798509.27919.25.camel@gandalf.local.home>
	 <50468778.5000207@redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pedro Alves <palves@redhat.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Tue, 2012-09-04 at 23:58 +0100, Pedro Alves wrote:

> Not true.  The comma operator introduces a sequence point.  It's the comma
> that separates function parameters that doesn't guarantee ordering.

Bah! C language is almost as confusing as English.

-- Steve



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
