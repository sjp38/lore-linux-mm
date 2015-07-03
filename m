Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id ACD8B280281
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 16:47:16 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so82381124ieb.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 13:47:16 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id a2si10030439icw.50.2015.07.03.13.47.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 13:47:15 -0700 (PDT)
Received: by igcur8 with SMTP id ur8so151411390igc.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 13:47:15 -0700 (PDT)
Message-ID: <5596F4D1.5080706@gmail.com>
Date: Fri, 03 Jul 2015 16:47:13 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
References: <20150702072621.GB12547@dhcp22.suse.cz> <20150702160341.GC9456@thunk.org> <55956204.2060006@gmail.com> <20150703144635.GE9456@thunk.org> <5596A20F.6010509@gmail.com> <20150703150117.GA3688@dhcp22.suse.cz> <5596A42F.60901@gmail.com> <20150703164944.GG9456@thunk.org> <5596BDB6.5060708@gmail.com> <20150703184501.GJ9456@thunk.org> <20150703201331.GF6812@suse.de>
In-Reply-To: <20150703201331.GF6812@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2015-07-03 04:13 PM, Mel Gorman wrote:
> On Fri, Jul 03, 2015 at 02:45:02PM -0400, Theodore Ts'o wrote:
>> On Fri, Jul 03, 2015 at 12:52:06PM -0400, nick wrote:
>>> I agree with you 100 percent. The reason I can't test this is I don't have the
>>> hardware otherwise I would have tested it by now.
>>
>> Then don't send the patch out.  Work on some other piece of part of
>> the kernel, or better yet, some other userspace code where testing is
>> easier.  It's really quite simple.
>>
>> You don't have the technical skills, or at this point, the reputation,
>> to send patches without tesitng them first.  The fact that sometimes
>> people like Linus will send out a patch labelled with "COMPLETELY
>> UNTESTED", is because he's skilled and trusted enough that he can get
>> away with it.
> 
> It's not just that. In all cases I'm aware of, Linus was illustrating his
> point by means of a patch during a discussion. It was expected that the
> developer or user that started the discussion would take that patch and run
> with it if it was heading in the correct direction. In exceptional cases,
> the patch would be merged after a confirmation from that developer or user
> that the patch worked for whatever problem they faced. The only time I've
> seen a COMPLETELY UNTESTED patch merged was when it was painfully obvious it
> was correct and more importantly, it solved a specific problem. Linus is not
> the only developer that does this style of discussion through untested patch.
> 
> In other cases where an untested patch has been merged, it was either due to
> it being exceptionally trivial or a major API change that affects a number
> of subsystems (like adding a new filesystem API for example). In the former
> case, it's usually self-evident and often tacked onto a larger series where
> there is a degree of trust. In the latter case, all cases they can test
> have been covered and the code for the remaining hardware was altered in
> a very similar manner. This also lends some confidence that the transform
> is ok because similar transforms were tested and known to be correct.
> 
> For trivial patches that alter just return values there are a few hazards. A
> mistake can be made introducing a real bug with the upside being marginal or
> non-existent. That's a very poor tradeoff and generally why checkpatch-only
> patches fall by the wayside. Readability is a two-edged sword. Maybe the
> code is marginally easier to read but it's sometimes offset by the fact
> that git blame no longer points to the important origin of the code. If
> a real bug is being investigated then all the cleanup patches have to be
> identified and dismissed which consumes time and concentration.
> 
> Cleanups in my opinion are ok in two cases. The first is if it genuinely
> makes the code much easier to follow. In cases where I've seen this, it was
> done because the code was either unreadable or it was in preparation for a
> more relevant patch series that was then easier to review and justified the
> cleanup. The second is where the affected code is being heavily modified
> anyway so the cleanup while you are there is both useful and does not
> impact git blame.
> 
> This particular patch does not match any of the criteria. The DRM patch
> may or may not be correct but there is no way I'd expect something like
> it to be picked up without testing or in reference to a bug report.
> 
> For this patch, NAK. Nick, from me at least consider any similar patch
> affecting mm/ that modifies return values or types without being part of
> a larger series that addresses a particular problem to be silently NAKed
> or filed under "doesn't matter" by me.
> 
I am no longer going to do cleanups as they are a waste of mine and the maintainers,
thanks for pointing that out through Mel. However I did find a bad commit with the id 7202ab46f7392265c1ecbf03f600393bf32a8bdf that breaks and hangs my system on boot so
bad I can't even get into single user mode. Either one of the maintainers of that
code can revert it or we can find a proper fix to it on my broken machine with this
commit. In addition all of my patches for cleanups that don't remove unused
code have been removed, there of no use. However this patch has been on my system
for a month and is an important cleanup as it removes other 100 lines of unused
code. I also have another function removal patch for both chelsio drivers and
the mailbox api that are staying around due to them being useful in terms of 
removing old/unused code. 
Thanks A lot for Your and Ted's Time,
Nick 
