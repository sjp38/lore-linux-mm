Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A08396B002D
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 12:43:10 -0500 (EST)
Received: by iaek3 with SMTP id k3so1269407iae.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 09:43:08 -0800 (PST)
Date: Wed, 16 Nov 2011 09:43:02 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] PM/Memory-hotplug: Avoid task freezing failures
Message-ID: <20111116174302.GD18919@google.com>
References: <20111116115515.25945.35368.stgit@srivatsabhat.in.ibm.com>
 <20111116162601.GB18919@google.com>
 <4EC3F146.7050801@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EC3F146.7050801@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: rjw@sisk.pl, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

Hello,

On Wed, Nov 16, 2011 at 10:52:14PM +0530, Srivatsa S. Bhat wrote:
> So, honestly I didn't understand what is wrong with the approach of this
> patch. And as a consequence, I don't see why we should wait to fix this
> issue. 
> 
> [And by the way recently I happened to see yet another proposed patch
> trying to make use of this API. So wouldn't it be better to fix this
> ASAP, especially when we have a fix readily available?]

It just doesn't look like a proper solution.  Nothing guarantees
freezing will happen soonish.  Not all pm operations involve freezer.
The exclusion is against mem hotplug at this point, right?  I don't
think it's a good idea to add such hack to fix a mostly theoretical
problem and it's actually quite likely someone would be scratching
head trying to figure out why the hell the CPU was hot spinning while
the system is trying to enter one of powersaving mode (we had similar
behavior in freezer code a while back and it was ugly).

So, let's either fix it properly or leave it alone.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
