Message-ID: <46960C27.5040803@qumranet.com>
Date: Thu, 12 Jul 2007 14:10:31 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: lguest, Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <20070711122324.GA21714@lst.de>	 <1184203311.6005.664.camel@localhost.localdomain>	 <20070711.192829.08323972.davem@davemloft.net>	 <1184208521.6005.695.camel@localhost.localdomain>	 <20070711212435.abd33524.akpm@linux-foundation.org> <1184215943.6005.745.camel@localhost.localdomain>
In-Reply-To: <1184215943.6005.745.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hch@lst.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rusty Russell wrote:
> Remove export of __put_task_struct, and usage in lguest
>
> lguest takes a reference count of tasks for two reasons.  The first is
> bogus: the /dev/lguest close callback will be called before the task
> is destroyed anyway, so no need to take a reference on open.
>
>   

What about

  Open /dev/lguest
  transfer fd using SCM_RIGHTS (or clone()?)
  close fd in original task
  exit()

?

My feeling is that if you want to be bound to a task, not a file, you 
need to use syscalls, not ioctls.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
