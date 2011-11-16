Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2FCED6B0070
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 16:45:01 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v2] PM/Memory-hotplug: Avoid task freezing failures
Date: Wed, 16 Nov 2011 22:47:38 +0100
References: <20111116115515.25945.35368.stgit@srivatsabhat.in.ibm.com> <4EC3FFC4.2010904@linux.vnet.ibm.com> <20111116184157.GA25497@google.com>
In-Reply-To: <20111116184157.GA25497@google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201111162247.39217.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Wednesday, November 16, 2011, Tejun Heo wrote:
> Hello,
> 
> On Wed, Nov 16, 2011 at 11:54:04PM +0530, Srivatsa S. Bhat wrote:
> > Ok, so by "proper solution", are you referring to a totally different
> > method (than grabbing pm_mutex) to implement mutual exclusion between
> > subsystems and suspend/hibernation, something like the suspend blockers
> > stuff and friends?
> > Or are you hinting at just the existing code itself being fixed more
> > properly than what this patch does, to avoid having side effects like
> > you pointed out?
> 
> Oh, nothing fancy.  Just something w/o busy looping would be fine.
> The stinking thing is we don't have mutex_lock_freezable().  Lack of
> proper freezable interface seems to be a continuing problem and I'm
> not sure what the proper solution should be at this point.  Maybe we
> should promote freezable to a proper task state.  Maybe freezable
> kthread is a bad idea to begin with.

It generally is, but some of them really want to be freezable.

> Maybe instead of removing
> freezable_with_signal() we should make that default, that way,
> freezable can hitch on the pending signal handling (this creates
> another set of problems tho - ie. who's responsible for clearing
> TIF_SIGPENDING?).  I don't know.
> 
> Maybe just throw in msleep(10) there with fat ugly comment explaining
> why the hack is necessary?

Perhaps.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
