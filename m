Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A453B90010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 18:12:41 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p4CMCeAZ013099
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:12:40 -0700
Received: from pwi16 (pwi16.prod.google.com [10.241.219.16])
	by wpaz37.hot.corp.google.com with ESMTP id p4CMBbSh017278
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:12:39 -0700
Received: by pwi16 with SMTP id 16so1360734pwi.7
        for <linux-mm@kvack.org>; Thu, 12 May 2011 15:12:38 -0700 (PDT)
Date: Thu, 12 May 2011 15:12:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
In-Reply-To: <1305076850.19586.196.camel@Joe-Laptop>
Message-ID: <alpine.DEB.2.00.1105121510330.9130@chino.kir.corp.google.com>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org> <1305073386-4810-3-git-send-email-john.stultz@linaro.org> <1305075090.19586.189.camel@Joe-Laptop>  <1305076246.2939.67.camel@work-vm> <1305076850.19586.196.camel@Joe-Laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 10 May 2011, Joe Perches wrote:

> > Although I'm not sure if there's precedent for a %p value that didn't
> > take a argument. Thoughts on that? Anyone else have an opinion here?
> 
> The uses of %ptc must add an argument or else gcc will complain.
> I suggest you just ignore the argument value and use current.
> 

That doesn't make any sense, why would you needlessly restrict this to 
current when accesses to other threads' ->comm needs to be protected in 
the same way?  I'd like to use this in the oom killer and try to get rid 
of taking task_lock() for every thread group leader in the tasklist dump.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
