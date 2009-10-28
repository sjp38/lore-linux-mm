Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 660B16B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:10:53 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n9SKAnVN029100
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:10:50 -0700
Received: from pxi29 (pxi29.prod.google.com [10.243.27.29])
	by spaceape9.eur.corp.google.com with ESMTP id n9SKAIGV013417
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:10:46 -0700
Received: by pxi29 with SMTP id 29so750252pxi.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:10:46 -0700 (PDT)
Date: Wed, 28 Oct 2009 13:10:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <4AE846E8.1070303@gmail.com>
Message-ID: <alpine.DEB.2.00.0910281307370.23279@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
 <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com>
 <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <4AE846E8.1070303@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Vedran Furac <vedran.furac@gmail.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009, Vedran Furac wrote:

> > Those are practically happening simultaneously with very little memory 
> > being available between each oom kill.  Only later is "test" killed:
> > 
> > [97240.203228] Out of memory: kill process 5005 (test) score 256912 or a child
> > [97240.206832] Killed process 5005 (test)
> > 
> > Notice how the badness score is less than 1/4th of the others.  So while 
> > you may find it to be hogging a lot of memory, there were others that 
> > consumed much more.
> ^^^^^^^^^^^^^^^^^^^^^
> 
> This is just wrong. I have 3.5GB of RAM, free says that 2GB are empty
> (ignoring cache). Culprit then allocates all free memory (2GB). That
> means it is using *more* than all other processes *together*. There
> cannot be any other "that consumed much more".
> 

Just post the oom killer results after using echo 1 > 
/proc/sys/vm/oom_dump_tasks as requested and it will clarify why those 
tasks were chosen to kill.  It will also show the result of using rss 
instead of total_vm and allow us to see how such a change would have 
changed the killing order for your workload.

> Thanks, I'll try that... but I guess that using rss would yield better
> results.
> 

We would know if you posted the data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
