Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C1B406B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 18:34:15 -0400 (EDT)
Date: Thu, 12 May 2011 15:34:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] comm: ext4: Protect task->comm access by using %ptc
Message-Id: <20110512153411.15c240bc.akpm@linux-foundation.org>
In-Reply-To: <1305239380.2680.26.camel@work-vm>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
	<1305073386-4810-4-git-send-email-john.stultz@linaro.org>
	<alpine.DEB.2.00.1105121513070.9130@chino.kir.corp.google.com>
	<1305239380.2680.26.camel@work-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

On Thu, 12 May 2011 15:29:40 -0700
John Stultz <john.stultz@linaro.org> wrote:

> On Thu, 2011-05-12 at 15:14 -0700, David Rientjes wrote:
> > On Tue, 10 May 2011, John Stultz wrote:
> > 
> > > Converts ext4 comm access to use the safe printk %ptc accessor.
> > > 
> > > CC: Ted Ts'o <tytso@mit.edu>
> > > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > CC: David Rientjes <rientjes@google.com>
> > > CC: Dave Hansen <dave@linux.vnet.ibm.com>
> > > CC: Andrew Morton <akpm@linux-foundation.org>
> > > CC: linux-mm@kvack.org
> > > Signed-off-by: John Stultz <john.stultz@linaro.org>
> > 
> > I like how this patch illustrates how easy it is to use the new method for 
> > printing a task's command, but it would probably be easier to get the 
> > first two patches in the series (those that add the seqlock and then %ptc) 
> > merged in mainline and then break out a series of conversions such as this 
> > that could go through the individual maintainer's trees.
> 
> Agreed. I just wanted to show how it would be used compared to the
> earlier approach.
> 
> I'll respin the first two patches shortly here. I also need to get the
> checkpatch bit done.
> 
> Andrew, should these go upstream through you?
> 

That works.  I have a little pile of task->comm patches here, but I
expect that resolving everything will be pretty straightforward.

Don't forget the checkpatch patch :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
