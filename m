Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 417D8280246
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 12:08:43 -0400 (EDT)
Received: by iecvh10 with SMTP id vh10so59927611iec.3
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 09:08:43 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id q137si6171037ioe.103.2015.07.02.09.08.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jul 2015 09:08:42 -0700 (PDT)
Received: by igcsj18 with SMTP id sj18so165936566igc.1
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 09:08:38 -0700 (PDT)
Message-ID: <55956204.2060006@gmail.com>
Date: Thu, 02 Jul 2015 12:08:36 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com> <20150702072621.GB12547@dhcp22.suse.cz> <20150702160341.GC9456@thunk.org>
In-Reply-To: <20150702160341.GC9456@thunk.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2015-07-02 12:03 PM, Theodore Ts'o wrote:
> On Thu, Jul 02, 2015 at 09:26:21AM +0200, Michal Hocko wrote:
>> On Wed 01-07-15 14:27:57, Nicholas Krause wrote:
>>> This makes the function zap_huge_pmd have a return type of bool
>>> now due to this particular function always returning one or zero
>>> as its return value.
>>
>> How does this help anything? IMO this just generates a pointless churn
>> in the code without a good reason.
> 
> Hi Michal,
> 
> My recommendation is to ignore patches sent by Nick.  In my experience
> he doesn't understand code before trying to make mechanical changes,
> and very few of his patches add any new value, and at least one that
> he tried to send me just 2 weeks or so ago (cherry-picked to try to
> "prove" why he had turned over a new leaf, so that I would support the
> removal of his e-mail address from being blacklisted on
> vger.kernel.org) was buggy, and when I asked him some basic questions
> about what the code was doing, it was clear he had no clue how the
> seq_file abstraction worked.  This didn't stop him from trying to
> patch the code, and if he had tested it, it would have crashed and
> burned instantly.
> 
> Of course, do whatevery you want, but IMHO it's not really not worth
> your time to deal with his patches, and if you reply, most people
> won't see his original e-mail since the vger.kernel.org blacklist is
> still in effect.
> 
> Regards,
> 
> 						- Ted
> 
Ted,
I looked into that patch further and would were correct it was wrong.
However here is a bug fix for the drm driver code that somebody else
stated was right but haven gotten a reply to from the maintainer and
have tried resending.
Nick
