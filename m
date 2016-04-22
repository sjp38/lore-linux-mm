Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8F426B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 18:44:24 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id z8so64845061igl.3
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 15:44:24 -0700 (PDT)
Received: from mail-ig0-x242.google.com (mail-ig0-x242.google.com. [2607:f8b0:4001:c05::242])
        by mx.google.com with ESMTPS id w74si12134692iod.51.2016.04.22.15.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 15:44:24 -0700 (PDT)
Received: by mail-ig0-x242.google.com with SMTP id qu10so3919031igc.1
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 15:44:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460748682.25336.41.camel@redhat.com>
References: <bug-107771-27@https.bugzilla.kernel.org/>
	<20160415121549.47e404e3263c71564929884e@linux-foundation.org>
	<1460748682.25336.41.camel@redhat.com>
Date: Fri, 22 Apr 2016 18:44:24 -0400
Message-ID: <CAK7bmU-7yD7+W6gS1Ka9svxnsAR6OGYD1xcwuNQLYuRjLQ1wtw@mail.gmail.com>
Subject: Re: [Bug 107771] New: Single process tries to use more than 1/2
 physical RAM, OS starts thrashing
From: Timothy Normand Miller <theosib@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>

On Fri, Apr 15, 2016 at 3:31 PM, Rik van Riel <riel@redhat.com> wrote:
> On Fri, 2016-04-15 at 12:15 -0700, Andrew Morton wrote:
>> (switched to email.  Please respond via emailed reply-to-all, not via
>> the
>> bugzilla web interface).
>>
>> This is ... interesting.
>
> First things first. What is the value of
> /proc/sys/vm/zone_reclaim?

There is no such thing on this system.  However:

$ cat /proc/sys/vm/zone_reclaim_mode
0

>
> I am assuming this is a two socket system,
> with two 12-core CPUs. Am I right?

Yes.

>
>> On Thu, 12 Nov 2015 18:46:35 +0000 bugzilla-
>> daemon@bugzilla.kernel.org wrote:
>>
>> >
>> > https://bugzilla.kernel.org/show_bug.cgi?id=107771
>> >
>> >             Bug ID: 107771
>> >            Summary: Single process tries to use more than 1/2
>> > physical
>> >                     RAM, OS starts thrashing
>> >            Product: Memory Management
>> >            Version: 2.5
>> >     Kernel Version: 4.3.0-040300-generic (Ubuntu)
>> >           Hardware: All
>> >                 OS: Linux
>> >               Tree: Mainline
>> >             Status: NEW
>> >           Severity: normal
>> >           Priority: P1
>> >          Component: Page Allocator
>> >           Assignee: akpm@linux-foundation.org
>> >           Reporter: theosib@gmail.com
>> >         Regression: No
>> >
>> > I have a 24-core (48 thread) system with 64GB of RAM.
>> >
>> > When I run multiple processes, I can use all of physical RAM before
>> > swapping
>> > starts.  However, if I'm running only a *single* process, the
>> > system will start
>> > swapping after I've exceeded only 1/2 of available physical
>> > RAM.  Only after
>> > swap fills does it start using more of the physical RAM.
>> >
>> > I can't find any ulimit settings or anything else that would cause
>> > this to
>> > happen intentionally.
>> >
>> > I had originally filed this against Ubuntu, but I'm now running a
>> > more recent
>> > kernel, and the problem persists, so I think it's more appropriate
>> > to file
>> > here.  There are some logs that they had me collect, so if you want
>> > to see
>> > them, the are here:
>> >
>> > https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1513673
>> >
>> > I don't recall this problem happening with older kernels (whatever
>> > came with
>> > Ubuntu 15.04), although I may just not have noticed.  By swapping
>> > early, I'm
>> > limited by the speed of my SSD, which is moving only about 20MB/sec
>> > in each
>> > direction, and that makes what I'm running take 10 times as long to
>> > complete.
>> >
> --
> All Rights Reversed.
>



-- 
Timothy Normand Miller, PhD
Assistant Professor of Computer Science, Binghamton University
http://www.cs.binghamton.edu/~millerti/
Open Graphics Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
