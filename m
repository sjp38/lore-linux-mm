Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5632802BB
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:26:28 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so32253320pdj.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:26:28 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id qz5si9546910pbb.239.2015.07.15.15.26.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Jul 2015 15:26:26 -0700 (PDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 15 Jul 2015 16:26:23 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 944853E40047
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:26:19 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6FMQJVb57344178
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:26:19 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6FMQJLt008041
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:26:19 -0600
Date: Wed, 15 Jul 2015 15:26:12 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: cpu_hotplug vs oom_notify_list: possible circular locking
 dependency detected
Message-ID: <20150715222612.GP3717@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150712105634.GA11708@marcin-Inspiron-7720>
 <alpine.DEB.2.10.1507141508590.16182@chino.kir.corp.google.com>
 <20150714232943.GW3717@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1507141647531.16182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1507141647531.16182@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@gmail.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Jul 14, 2015 at 04:48:24PM -0700, David Rientjes wrote:
> On Tue, 14 Jul 2015, Paul E. McKenney wrote:
> 
> > commit a1992f2f3b8e174d740a8f764d0d51344bed2eed
> > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Date:   Tue Jul 14 16:24:14 2015 -0700
> > 
> >     rcu: Don't disable CPU hotplug during OOM notifiers
> >     
> >     RCU's rcu_oom_notify() disables CPU hotplug in order to stabilize the
> >     list of online CPUs, which it traverses.  However, this is completely
> >     pointless because smp_call_function_single() will quietly fail if invoked
> >     on an offline CPU.  Because the count of requests is incremented in the
> >     rcu_oom_notify_cpu() function that is remotely invoked, everything works
> >     nicely even in the face of concurrent CPU-hotplug operations.
> >     
> >     Furthermore, in recent kernels, invoking get_online_cpus() from an OOM
> >     notifier can result in deadlock.  This commit therefore removes the
> >     call to get_online_cpus() and put_online_cpus() from rcu_oom_notify().
> >     
> >     Reported-by: Marcin A?lusarz <marcin.slusarz@gmail.com>
> >     Reported-by: David Rientjes <rientjes@google.com>
> >     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thank you!

Any news on whether or not it solves the problem?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
