Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E57E16B0012
	for <linux-mm@kvack.org>; Fri, 13 May 2011 14:28:55 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4DICW97001938
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:12:32 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p4DISjhX161760
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:28:45 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4DCSHcj028405
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:28:18 -0600
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for current->comm
 references
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <4DCD1271.3070808@jp.fujitsu.com>
References: <1305241371-25276-1-git-send-email-john.stultz@linaro.org>
	 <1305241371-25276-4-git-send-email-john.stultz@linaro.org>
	 <4DCD1271.3070808@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 13 May 2011 11:28:41 -0700
Message-ID: <1305311321.2680.35.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, 2011-05-13 at 20:13 +0900, KOSAKI Motohiro wrote:
> >   scripts/checkpatch.pl |    4 ++++
> >   1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> > index d867081..9d2eab5 100755
> > --- a/scripts/checkpatch.pl
> > +++ b/scripts/checkpatch.pl
> > @@ -2868,6 +2868,10 @@ sub process {
> >   			WARN("usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" . $herecurr);
> >   		}
> > 
> > +# check for current->comm usage
> > +		if ($line =~ /current->comm/) {
> > +			WARN("comm access needs to be protected. Use get_task_comm, or printk's \%ptc formatting.\n" . $herecurr);
> 
> I think we should convert all of task->comm usage. not only current. At least, you plan to remove task_lock() from
> %ptc patch later.

Yea, I'll be updating the patch to try to catch more then just
current->comm.

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
