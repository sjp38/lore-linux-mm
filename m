Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82FED6B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 19:01:16 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id js7so185384933obc.0
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 16:01:16 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id jw14si6269909igc.97.2016.04.22.16.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 16:01:15 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id u185so16425930iod.2
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 16:01:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160417185327.GC9051@dhcp22.suse.cz>
References: <bug-107771-27@https.bugzilla.kernel.org/>
	<20160415121549.47e404e3263c71564929884e@linux-foundation.org>
	<1460748682.25336.41.camel@redhat.com>
	<20160417185327.GC9051@dhcp22.suse.cz>
Date: Fri, 22 Apr 2016 19:01:15 -0400
Message-ID: <CAK7bmU94X1wH3-Ld-onwb895rEUMPCRUgz39PpFLRMkLsbxCqQ@mail.gmail.com>
Subject: Re: [Bug 107771] New: Single process tries to use more than 1/2
 physical RAM, OS starts thrashing
From: Timothy Normand Miller <theosib@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>

On Sun, Apr 17, 2016 at 2:53 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 15-04-16 15:31:22, Rik van Riel wrote:
>> On Fri, 2016-04-15 at 12:15 -0700, Andrew Morton wrote:
>> > (switched to email.  Please respond via emailed reply-to-all, not via
>> > the
>> > bugzilla web interface).
>> >
>> > This is ... interesting.
>>
>> First things first. What is the value of
>> /proc/sys/vm/zone_reclaim?
>
> Also snapshots of /proc/vmstat taken every 1s or so while you see the
> trashing would be helpful.

It's been so long since I reported this bug that I don't recall
exactly what I was doing.  I think I was running Synopsys.  I tried
artificially reproducing this by just allocating a huge amount of
memory and touching all the pages, but the problem didn't manifest.  I
wonder if Synopsys was allocating pages it didn't touch or mmaping
files or some other weird thing.


> --
> Michal Hocko
> SUSE Labs



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
