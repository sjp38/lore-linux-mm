Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 40F106B0031
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 10:00:24 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 20 Jul 2013 08:00:20 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 52D323E4001C
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 07:59:56 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6KE0Hia097956
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 08:00:17 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6KE2sDm032039
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 08:02:55 -0600
Date: Sat, 20 Jul 2013 07:00:15 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: mlockall triggred rcu_preempt stall.
Message-ID: <20130720140015.GA5860@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130719145323.GA1903@redhat.com>
 <20130719221538.GH21367@linux.vnet.ibm.com>
 <20130720003212.GA31308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130720003212.GA31308@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kosaki.motohiro@gmail.com, walken@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Fri, Jul 19, 2013 at 08:32:12PM -0400, Dave Jones wrote:
> On Fri, Jul 19, 2013 at 03:15:39PM -0700, Paul E. McKenney wrote:
>  > On Fri, Jul 19, 2013 at 10:53:23AM -0400, Dave Jones wrote:
>  > > My fuzz tester keeps hitting this. Every instance shows the non-irq stack
>  > > came in from mlockall.  I'm only seeing this on one box, but that has more
>  > > ram (8gb) than my other machines, which might explain it.
>  > 
>  > Are you building CONFIG_PREEMPT=n?  I don't see any preemption points in
>  > do_mlockall(), so a range containing enough vmas might well stall the
>  > CPU in that case.  
> 
> That was with full preempt.
> 
>  > Does the patch below help?  If so, we probably need others, but let's
>  > first see if this one helps.  ;-)
> 
> I'll try it on Monday.

Given full preempt, I wouldn't think that my patch would have any effect,
but look forward to hearing what happens.

Hmmm....  Were you running mlockall() concurrently from a bunch of
different processes sharing lots of memory via mmap() or some such?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
