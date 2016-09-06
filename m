Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5716B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 07:10:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w12so25877541wmf.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 04:10:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m133si22731603wma.144.2016.09.06.04.10.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 04:10:05 -0700 (PDT)
Subject: Re: OOM killer changes
References: <e867d795-224f-5029-48c9-9ce515c0b75f@Quantum.com>
 <f050bc92-d2f1-80cc-f450-c5a57eaf82f0@suse.cz>
 <ea18e6b3-9d47-b154-5e12-face50578302@Quantum.com>
 <f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz>
 <20160819073359.GA32619@dhcp22.suse.cz>
 <d443b884-87e7-1c93-8684-3a3a35759fb1@suse.cz>
 <20160819082639.GE32619@dhcp22.suse.cz>
 <a43170bc-4464-487f-140b-966f58f9bddf@Quantum.com>
 <20160825072219.GD4230@dhcp22.suse.cz>
 <2f897a0c-e27d-7ad7-dd0c-6b1e0d3fb2b4@Quantum.com>
 <20160826083553.GE16195@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6aa5d4b7-c5e6-c141-9d92-adf1a14c53c9@suse.cz>
Date: Tue, 6 Sep 2016 13:09:57 +0200
MIME-Version: 1.0
In-Reply-To: <20160826083553.GE16195@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/26/2016 10:35 AM, Michal Hocko wrote:
> On Thu 25-08-16 13:35:04, Ralf-Peter Rohbeck wrote:
> [...]
>> Sorry, the tag was next-20160823; I called the branch linux-next-20160823.
>
> Yeah that is the tag I was looking for but the linux-next is quite
> volatile and if you do not fetch the particular tag it won't exist in
> leter trees. Anyway, I have set up a branch oom-playground in my tree
> git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git which which
> is on top of the current up-to-date mmotm tree + revert of the quick
> workaround which you have already tested (thanks for that!) and with
> the Vlastimil's patch which was dropped due to workaround.

This is missing the patch that introduced ignoring pageblock suitability 
for the highest compaction priority [1].

> AFAIU this
> is what you have previously tested without OOM but later on still
> managed to hit OOM again.

I think the test also didn't include the patch [1] due to some 
confusion. I think I'll just resend everything (in a new thread) for 
testing on top of latest mmotm git.

[1] http://marc.info/?l=linux-mm&m=147158805719821

> Which would suggest we are still not there
> and need to investigate further. I have some ideas what to do but I
> would appreciate if we can confirm this status before we try new things.
>
> Thanks!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
