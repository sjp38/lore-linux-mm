Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 4827D6B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 20:32:23 -0400 (EDT)
Date: Fri, 19 Jul 2013 20:32:12 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: mlockall triggred rcu_preempt stall.
Message-ID: <20130720003212.GA31308@redhat.com>
References: <20130719145323.GA1903@redhat.com>
 <20130719221538.GH21367@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130719221538.GH21367@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kosaki.motohiro@gmail.com, walken@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Fri, Jul 19, 2013 at 03:15:39PM -0700, Paul E. McKenney wrote:
 > On Fri, Jul 19, 2013 at 10:53:23AM -0400, Dave Jones wrote:
 > > My fuzz tester keeps hitting this. Every instance shows the non-irq stack
 > > came in from mlockall.  I'm only seeing this on one box, but that has more
 > > ram (8gb) than my other machines, which might explain it.
 > 
 > Are you building CONFIG_PREEMPT=n?  I don't see any preemption points in
 > do_mlockall(), so a range containing enough vmas might well stall the
 > CPU in that case.  

That was with full preempt.

 > Does the patch below help?  If so, we probably need others, but let's
 > first see if this one helps.  ;-)

I'll try it on Monday.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
