Date: Mon, 7 Jul 2008 08:35:19 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: next-0704: WARNING: at kernel/sched.c:4254 add_preempt_count;
	PANIC
Message-ID: <20080707063519.GE23583@elte.hu>
References: <487159DA.708@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <487159DA.708@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Alexander Beregalov <a.beregalov@gmail.com> wrote:

> Hi
> 
> WARNING: at kernel/sched.c:4254 add_preempt_count+0x61/0x63()
> Modules linked in: i2c_nforce2
> Pid: 3620, comm: rtorrent Not tainted 2.6.26-rc8-next-20080704 #5

this warning is what triggers:

 #ifdef CONFIG_DEBUG_PREEMPT
         /*
          * Underflow?
          */
         if (DEBUG_LOCKS_WARN_ON((preempt_count() < 0)))
                 return;

i.e. preempt counter underflow. That can happen either due to unbalanced 
preempt_disable()/preempt_enable() pairs, or can happen due to stack 
overflow/corruption.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
