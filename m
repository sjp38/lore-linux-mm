Received: from mailrelay1.lanl.gov (localhost.localdomain [127.0.0.1])
	by mailwasher-b.lanl.gov (8.12.10/8.12.10/(ccn-5)) with ESMTP id i16N6jHR000946
	for <linux-mm@kvack.org>; Fri, 6 Feb 2004 16:06:45 -0700
Subject: Re: 2.6.2-mm1 problem with umounting reiserfs
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20040206143917.4e39b215.akpm@osdl.org>
References: <1076104945.1793.12.camel@spc.esa.lanl.gov>
	 <20040206143917.4e39b215.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1076108684.1793.19.camel@spc.esa.lanl.gov>
Mime-Version: 1.0
Date: Fri, 06 Feb 2004 16:04:44 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-02-06 at 15:39, Andrew Morton wrote:
> Steven Cole <elenstev@mesatop.com> wrote:
> >
> > With kernel 2.6.2-mm1, I got the following when umounting a reiserfs
> > file system.

> 
> Squish.  Thanks.
> 
> 
> diff -puN kernel/workqueue.c~cpuhotplug-03-core-workqueue-fix kernel/workqueue.c
> --- 25/kernel/workqueue.c~cpuhotplug-03-core-workqueue-fix	Fri Feb  6 14:36:04 2004
> +++ 25-akpm/kernel/workqueue.c	Fri Feb  6 14:36:41 2004
> @@ -335,7 +335,7 @@ void destroy_workqueue(struct workqueue_
>  		if (cpu_online(cpu))
>  			cleanup_workqueue_thread(wq, cpu);
>  	}
> -	list_del(&wq->list);
> +	del_workqueue(wq);
>  	unlock_cpu_hotplug();
>  	kfree(wq);
>  }
> 

Squish confirmed.  That was fast!

Now if someone can squish the xfs "i_size_write() called without i_sem"
that we're not supposed to continue to whine about...

Thanks,
Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
