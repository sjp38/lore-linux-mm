Date: Fri, 17 Jan 2003 19:46:00 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: 2.5.59-mm1
Message-ID: <20030117084600.GA26172@krispykreme>
References: <20030117002451.69f1eda1.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030117002451.69f1eda1.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> -cputimes_stat.patch
> 
>  Not to Linus's taste.

Pity, I just had another reason to use this today (Checking if a network
app was locking itself down to a cpu)

> -lockless-current_kernel_time.patch
> 
>  Is ia32-only.

We can fix that. Ive been avoiding it because it will take some non
trivial cleanup of our ppc64 time.c. Based on how often get_current_time
is appearing in profiles and also how gettimeofday has been known to
cause problems on large SMP (due to read_lock on xtime starving
write_lock in the timer irq) I think this should get merged.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
