From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: 2.6.2-mm1 problem with umounting reiserfs
Date: Sat, 07 Feb 2004 17:23:05 +1100
Sender: owner-linux-mm@kvack.org
Message-ID: <20040207082424.5987C2C21E@lists.samba.org>
References: <20040206143917.4e39b215.akpm@osdl.org>
Return-path: <owner-linux-mm@kvack.org>
In-reply-to: Your message of "Fri, 06 Feb 2004 14:39:17 -0800."
             <20040206143917.4e39b215.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Steven Cole <elenstev@mesatop.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

In message <20040206143917.4e39b215.akpm@osdl.org> you write:
> diff -puN kernel/workqueue.c~cpuhotplug-03-core-workqueue-fix kernel/workqueue.c
> --- 25/kernel/workqueue.c~cpuhotplug-03-core-workqueue-fix	Fri Feb  6 14:36:04 2004
> +++ 25-akpm/kernel/workqueue.c	Fri Feb  6 14:36:41 2004
> @@ -335,7 +335,7 @@ void destroy_workqueue(struct workqueue_
>  		if (cpu_online(cpu))
>  			cleanup_workqueue_thread(wq, cpu);
>  	}
> -	list_del(&wq->list);
> +	del_workqueue(wq);

Damn.  I added that conditional macro at the last minute, trying to
reduce the impact on non-hotplug-CPU.

Thanks for the fix,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
