Message-ID: <46851E43.3060001@redhat.com>
Date: Fri, 29 Jun 2007 10:59:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random> <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random> <46814829.8090808@redhat.com> <20070626105541.cd82c940.akpm@linux-foundation.org> <468439E8.4040606@redhat.com> <1183124309.5037.31.camel@localhost> <20070629141254.GA23310@v2.random>
In-Reply-To: <20070629141254.GA23310@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> BTW, hope the above numbers are measured before the trashing stage
> when the number of jobs per second is lower than 10. It'd be nice not
> to spend all that time in system time but after that point the system
> will shortly reach oom. It's more important to be fast and save cpu in
> "useful" conditions (like with <4000 tasks).

If the numbers were measured only in the thrashing stage,
mwait_idle would be the top CPU "user", not the scanning
code.

What I am trying to measure is more a question of system
robustness than performance.  We have seen a few cases
where the system took 2 hours to recover to a useful state
after running out of RAM, with enough free swap.

Linux needs to deal better with memory filling up. It
should start to swap instead of scanning pages for very
long periods of time and not recovering for a while.

>> Here's a fairly recent version of the patch if you want to try it on
>> your workload.  We've seen mixed results on somewhat larger systems,
>> with and without your split LRU patch.  I've started writing up those
>> results.  I'll try to get back to finishing up the writeup after OLS and
>> vacation.
> 
> This looks a very good idea indeed.

I'm definately going to give Lee's patch a spin.

> Also I'm stunned this is being compared to a java workload, java is a
> threaded beast 

Interestingly enough, both a heavy Java workload and this AIM7
test block on the anon_vma lock contention.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
