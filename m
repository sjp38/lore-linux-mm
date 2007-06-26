Message-ID: <46817DB0.80105@redhat.com>
Date: Tue, 26 Jun 2007 16:57:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random> <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random> <46814829.8090808@redhat.com> <20070626203743.GG7059@v2.random>
In-Reply-To: <20070626203743.GG7059@v2.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Tue, Jun 26, 2007 at 01:08:57PM -0400, Rik van Riel wrote:
>> Both the normal kernel and your kernel fall over once memory
>> pressure gets big enough, but they explode differently and
>> at different points.
> 
> Ok, at some point it's normal they start trashing. 

Yes, but I would hope that the system would be disk bound
at that time instead of CPU bound.

There was no swap IO going on yet, the system was just
wasting CPU time in the VM.

> Even if it may have a positive effect in practice, I still think the
> current racy behavior (randomly overstimating and randomly
> understimating the amount of work each task has to do depending of who
> adds and read the zone values first) isn't good.

Oh, I like your simplification of the code, too.

I was running the test to see if that patch could be
merged without any negative side effects, because I
would have liked to see it.

> Where exactly we get to the halting point (4300 vs 5105) isn't
> crucial, 

However, neither of the two seems to be IO bound
at that point...

> Hope the benchmark is repeatable.  This week
> I've been working on another project but I'll shortly try to install
> AIM and reproduce and see what happens by decreasing
> DEF_PRIORITY. Thanks for the testing!

Not only is the AIM7 test perfectly repeatable, it also
causes the VM to show some of the same behaviour that
customers are seeing in the field with large JVM workloads.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
