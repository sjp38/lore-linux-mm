Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6356B0024
	for <linux-mm@kvack.org>; Fri, 13 May 2011 17:57:14 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4DLv3el009114
	for <linux-mm@kvack.org>; Fri, 13 May 2011 14:57:03 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by hpaq6.eem.corp.google.com with ESMTP id p4DLuTPR031814
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 May 2011 14:57:01 -0700
Received: by pwj3 with SMTP id 3so1794606pwj.15
        for <linux-mm@kvack.org>; Fri, 13 May 2011 14:57:01 -0700 (PDT)
Date: Fri, 13 May 2011 14:56:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
In-Reply-To: <1305239342.6124.77.camel@Joe-Laptop>
Message-ID: <alpine.DEB.2.00.1105131455140.6451@chino.kir.corp.google.com>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org> <1305073386-4810-3-git-send-email-john.stultz@linaro.org> <1305075090.19586.189.camel@Joe-Laptop>  <1305076246.2939.67.camel@work-vm> <1305076850.19586.196.camel@Joe-Laptop>
 <alpine.DEB.2.00.1105121510330.9130@chino.kir.corp.google.com> <1305239342.6124.77.camel@Joe-Laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andy Whitcroft <apw@canonical.com>, John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, 12 May 2011, Joe Perches wrote:

> > > > Although I'm not sure if there's precedent for a %p value that didn't
> > > > take a argument. Thoughts on that? Anyone else have an opinion here?
> > > The uses of %ptc must add an argument or else gcc will complain.
> > > I suggest you just ignore the argument value and use current.
> > That doesn't make any sense, why would you needlessly restrict this to 
> > current when accesses to other threads' ->comm needs to be protected in 
> > the same way?  I'd like to use this in the oom killer and try to get rid 
> > of taking task_lock() for every thread group leader in the tasklist dump.
> 
> I suppose another view is coder stuffed up, let them suffer...
> 
> At some point, gcc may let us extend printf argument type
> verification so it may not be a continuing problem.
> 

I don't understand your respose, could you answer my question?  Printing 
the command of threads other than current isn't special.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
