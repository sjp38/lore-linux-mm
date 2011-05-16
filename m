Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CCF996B0028
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:34:18 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p4GLYHEH023415
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:34:17 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by wpaz37.hot.corp.google.com with ESMTP id p4GLY4Fw023192
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:34:16 -0700
Received: by pzk35 with SMTP id 35so3100196pzk.39
        for <linux-mm@kvack.org>; Mon, 16 May 2011 14:34:16 -0700 (PDT)
Date: Mon, 16 May 2011 14:34:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for task comm references
In-Reply-To: <op.vvlfaobx3l0zgt@mnazarewicz-glaptop>
Message-ID: <alpine.DEB.2.00.1105161431550.4353@chino.kir.corp.google.com>
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org> <1305580757-13175-4-git-send-email-john.stultz@linaro.org> <op.vvlfaobx3l0zgt@mnazarewicz-glaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: LKML <linux-kernel@vger.kernel.org>, John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 16 May 2011, Michal Nazarewicz wrote:

> > Now that accessing current->comm needs to be protected,
> > @@ -2868,6 +2868,10 @@ sub process {
> > 			WARN("usage of NR_CPUS is often wrong - consider using
> > cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" .
> > $herecurr);
> > 		}
> > +# check for current->comm usage
> > +		if ($line =~ /\b(?:current|task|tsk|t)\s*->\s*comm\b/) {
> 
> Not a checkpatch.pl expert but as far as I'm concerned, that looks reasonable.
> 
> I was sort of worried that t->comm could produce quite a few false positives
> but all its appearances in the kernel (seem to) refer to task.
> 

It's guaranteed to generate false positives since perf events uses a field 
of the same name to store a thread's comm, so I think the most important 
thing is for the checkpatch output to specify that this _may_ be a 
dereference of a thread's comm that needs get_task_comm() or %ptc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
