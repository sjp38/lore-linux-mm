Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA13749
	for <linux-mm@kvack.org>; Fri, 17 Jan 2003 01:05:44 -0800 (PST)
Date: Fri, 17 Jan 2003 01:06:58 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm1
Message-Id: <20030117010658.4900da96.akpm@digeo.com>
In-Reply-To: <20030117084600.GA26172@krispykreme>
References: <20030117002451.69f1eda1.akpm@digeo.com>
	<20030117084600.GA26172@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anton Blanchard <anton@samba.org> wrote:
>
>  
> > -cputimes_stat.patch
> > 
> >  Not to Linus's taste.
> 
> Pity, I just had another reason to use this today (Checking if a network
> app was locking itself down to a cpu)

You can query that with sched_getaffinity()

> > -lockless-current_kernel_time.patch
> > 
> >  Is ia32-only.
> 
> We can fix that. Ive been avoiding it because it will take some non
> trivial cleanup of our ppc64 time.c. Based on how often get_current_time
> is appearing in profiles

Have you some numbers handy?

> and also how gettimeofday has been known to
> cause problems on large SMP (due to read_lock on xtime starving
> write_lock in the timer irq) I think this should get merged.
> 

OK.  I've had basically zero success getting non-ia32 people to test these
patches, and breaking their build won't help that.

But yes, this code needs to go ahead.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
