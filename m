Date: Wed, 29 Mar 2006 16:29:55 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6.16] mm: POSIX Memory Lock
Message-Id: <20060329162955.7d56367c.akpm@osdl.org>
In-Reply-To: <bc56f2f0603290531v2680a403tb30ad1bf94cc1d68@mail.gmail.com>
References: <bc56f2f0603290531v2680a403tb30ad1bf94cc1d68@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Stone Wang" <pwstone@gmail.com> wrote:
>
> Currently, Linux's mlock series memory locks/unlocks may fail with
> part of their jobs done, thus may confuse the programmers of which
> part of memory is locked, which is not.
> 
> While a better implementation is transaction-like POSIX memory lock.
> 
> POSIX mlock/munlock :
> 
> http://www.opengroup.org/onlinepubs/009695399/functions/mlock.html
> 
> RETURN VALUE
> 
>    Upon successful completion, the mlock() and munlock() functions
> shall return a value of zero. Otherwise, no change is made to any
> locks in the address space of the process, and the function shall
> return a value of -1 and set errno to indicate the error.
> 
> POSIX mlockall/munlockall :
> 
> http://www.opengroup.org/onlinepubs/009695399/functions/mlockall.html
> 
> RETURN VALUE
> 
>    Upon successful completion, the mlockall() function shall return a
> value of zero.  Otherwise, no additional memory shall be locked, and
> the function shall return a value of -1 and set errno to indicate the
> error. The effect of failure of mlockall() on previously existing
> locks in the address space is unspecified.
> 
>    If it is supported by the implementation, the munlockall() function
> shall always return a value of zero. Otherwise, the function shall
> return a value of -1 and set errno to indicate the error.
> 
> 
> The patch try to fix this, tests proved it works.
> 
> Nick Piggin suggested that the patch submited alone, as well as using 1 bit of
> vm_flags instead of adding 1 member to vm_area_struct. Special thanks to him.
> Besides, the patch is largely rewritten to make it clearer.
> 

Thanks.  This will take about an hour to review :( VMA merging and
splitting aren't the simplest things in the world.

Anyway, I'll queue it up for some testing - but I'm not sure when I (or
anyone else) will have the bandwidth for a line-by-line review, and that's
what it needs.

The mlockall/munlockall approach is nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
