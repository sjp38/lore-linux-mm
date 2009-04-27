Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 950176B00C5
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:31:32 -0400 (EDT)
Date: Mon, 27 Apr 2009 13:27:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: meminfo Committed_AS underflows
Message-Id: <20090427132722.926b07f1.akpm@linux-foundation.org>
In-Reply-To: <20090415084713.GU7082@balbir.in.ibm.com>
References: <20090415105033.AC29.A69D9226@jp.fujitsu.com>
	<20090415033455.GS7082@balbir.in.ibm.com>
	<20090415130042.AC3D.A69D9226@jp.fujitsu.com>
	<20090415084713.GU7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ebmunson@us.ibm.com, mel@linux.vnet.ibm.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Apr 2009 14:17:13 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 13:10:06]:
> 
> > > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 11:04:59]:
> > > 
> > > >  	committed = atomic_long_read(&vm_committed_space);
> > > > +	if (committed < 0)
> > > > +		committed = 0;
> > > 

Is there a reason why we can't use a boring old percpu_counter for
vm_committed_space?  That way the meminfo code can just use
percpu_counter_read_positive().

Or perhaps just percpu_counter_read().  The percpu_counter code does a
better job of handling large cpu counts than the
mysteriously-duplicative open-coded stuff we have there.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
