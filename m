Message-ID: <468162CD.6000208@redhat.com>
Date: Tue, 26 Jun 2007 15:02:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random>	<466C36AE.3000101@redhat.com>	<20070610181700.GC7443@v2.random>	<46814829.8090808@redhat.com> <20070626105541.cd82c940.akpm@linux-foundation.org>
In-Reply-To: <20070626105541.cd82c940.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 26 Jun 2007 13:08:57 -0400 Rik van Riel <riel@redhat.com> wrote:
> 
>>> If all tasks spend 10 minutes in shrink_active_list before the first
>>> call to shrink_inactive_list that could mean you hit the race that I'm
>>> just trying to fix with this very patch. 
>> I got around to testing it now.  I am using AIM7 since it is
>> a very anonymous memory heavy workload.
>>
>> Unfortunately your patch does not fix the problem, but behaves
>> as I had feared :(
>>
>> Both the normal kernel and your kernel fall over once memory
>> pressure gets big enough, but they explode differently and
>> at different points.
>>
>> I am running the test on a quad core x86-64 system with 2GB
>> memory.  I am "zooming in" on the 4000 user range, because
>> that is where they start to diverge.  I am running aim7 to
>> cross-over, which is the point at which fewer than 1 jobs/min/user
>> are being completed.
> 
> with what command line and config scripts does one run aim7 to
> reproduce this?

reaim -x -i 100 -s 5000

Using the default reaim.config and workfile.shared

> Where's the system time being spent?

I will run the tests again with profiling enabled.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
