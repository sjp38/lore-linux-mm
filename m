Received: by ug-out-1314.google.com with SMTP id s2so768676uge
        for <linux-mm@kvack.org>; Sat, 12 May 2007 02:27:41 -0700 (PDT)
Date: Sat, 12 May 2007 11:27:13 +0200 (CEST)
From: Esben Nielsen <nielsen.esben@googlemail.com>
Subject: Re: [PATCH 0/2] convert mmap_sem to a scalable rw_mutex
In-Reply-To: <20070511131541.992688403@chello.nl>
Message-ID: <Pine.LNX.4.64.0705121120210.26287@frodo.shire>
References: <20070511131541.992688403@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>


On Fri, 11 May 2007, Peter Zijlstra wrote:

>
> I was toying with a scalable rw_mutex and found that it gives ~10% reduction in
> system time on ebizzy runs (without the MADV_FREE patch).
>

You break priority enheritance on user space futexes! :-(
The problems is that the futex waiter have to take the mmap_sem. And as 
your rw_mutex isn't PI enabled you get priority inversions :-(

Esben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
