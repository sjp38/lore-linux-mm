Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 600846B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 15:44:06 -0400 (EDT)
Subject: Re: [PATCH 2/2] sched: make sched_param arugment static variables
 in some sched_setscheduler() caller
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100706170220.f3219001.akpm@linux-foundation.org>
References: <20100702144941.8fa101c3.akpm@linux-foundation.org>
	 <20100706091607.CCCC.A69D9226@jp.fujitsu.com>
	 <20100706095013.CCD9.A69D9226@jp.fujitsu.com>
	 <1278454438.1537.54.camel@gandalf.stny.rr.com>
	 <20100706161253.79bfb761.akpm@linux-foundation.org>
	 <1278460187.1537.107.camel@gandalf.stny.rr.com>
	 <20100706170220.f3219001.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 07 Jul 2010 21:43:46 +0200
Message-ID: <1278531826.1946.117.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rostedt@goodmis.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-06 at 17:02 -0700, Andrew Morton wrote:
> > Well this is also the way sched.c adds all its extra code.
>=20
> The sched.c hack sucks too.=20

Agreed, moving things to kernel/sched/ and adding some internal.h thing
could cure that, but I simply haven't gotten around to cleaning that
up..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
