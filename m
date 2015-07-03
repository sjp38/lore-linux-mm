Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE3A280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 10:54:09 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so77950100ieb.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 07:54:09 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com. [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id a5si1478822igm.0.2015.07.03.07.54.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 07:54:08 -0700 (PDT)
Received: by iecuq6 with SMTP id uq6so78099524iec.2
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 07:54:08 -0700 (PDT)
Message-ID: <5596A20F.6010509@gmail.com>
Date: Fri, 03 Jul 2015 10:54:07 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com> <20150702072621.GB12547@dhcp22.suse.cz> <20150702160341.GC9456@thunk.org> <55956204.2060006@gmail.com> <20150703144635.GE9456@thunk.org>
In-Reply-To: <20150703144635.GE9456@thunk.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2015-07-03 10:46 AM, Theodore Ts'o wrote:
> On Thu, Jul 02, 2015 at 12:08:36PM -0400, nick wrote:
>> I looked into that patch further and would were correct it was wrong.
>> However here is a bug fix for the drm driver code that somebody else
>> stated was right but haven gotten a reply to from the maintainer and
>> have tried resending.
> 
> Hi Nick,
> 
> Don't bother sending more low-value patches like this; they don't
> impress me.  Send me a patch that fixes a deep bug, where you can
> demonstrate that you understand the underlying design of the code, can
> point out a flaw, and then explain why your patch is an improvement,
> and documents how you tested it.  Or do something beyond changing
> return values or return types, and optimize some performance-critical
> part of the kernel, and in the commit description, explain why it
> improves things, how you measured the performance improvement, and why
> this is applicable in a real-life situation.
> 
> Even a broken clock can be right twice a day, and the fact that it is
> possible that you can author a correct patch isn't all that
> impressive.  You need to understand deep understanding of the code you
> are modifying, and or else it's not worth my time to go through a
> large number of low-value patches that don't really improve the code
> base much, when the risk that you have accidentally introduced a bug
> is high given that (a) you've demonstrated an inability to explain
> some of your patches, and (b) in many cases, you have no fear about
> sending patches that you can't personally test.  These two
> shortcomings in combination are fatal.
> 
> If you can demonstrate that you can become a thoughtful and careful
> coder, I would be most pleased to argue to Greg K-H that you have
> turned over a new leaf.  To date, however, you have not demonstrated
> any of the above, and you've made me regret that I've tried to waste
> time looking at your patches that you've sent me in the hopes of
> convincing me that you've really changed --- when it's clear you
> haven't.  I do hope that, one day, you will be able to be a good
> coder.  But that day is clearly not today.
> 
> Best regards,
> 
> 					- Ted
> 
Did you even look at the other patches I send you. Here is a bug fix for the gma500 driver code
that someone else stated is right but I don't have the hardware so it's difficult to test.
Nick
