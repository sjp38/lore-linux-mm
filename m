Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id C16726B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 11:23:11 -0500 (EST)
Received: by mail-vc0-f180.google.com with SMTP id hy10so589754vcb.11
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:23:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id vw3si9362758vcb.30.2015.01.22.08.23.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 08:23:10 -0800 (PST)
Message-ID: <54C123CF.2070107@redhat.com>
Date: Thu, 22 Jan 2015 11:22:39 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, vmacache: Add kconfig VMACACHE_SHIFT
References: <1421908189-18938-1-git-send-email-chaowang@redhat.com>	 <1421912761.4903.22.camel@stgolabs.net>	 <20150122075742.GA11335@dhcp-129-179.nay.redhat.com> <1421943573.4903.24.camel@stgolabs.net>
In-Reply-To: <1421943573.4903.24.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>, WANG Chao <chaowang@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/22/2015 11:19 AM, Davidlohr Bueso wrote:
> On Thu, 2015-01-22 at 15:57 +0800, WANG Chao wrote:
>> Hi, Davidlohr
>>
>> On 01/21/15 at 11:46pm, Davidlohr Bueso wrote:
>>> On Thu, 2015-01-22 at 14:29 +0800, WANG Chao wrote:
>>>> Add a new kconfig option VMACACHE_SHIFT (as a power of 2) to specify the
>>>> number of slots vma cache has for each thread. Range is chosen 0-4 (1-16
>>>> slots) to consider both overhead and performance penalty. Default is 2
>>>> (4 slots) as it originally is, which provides good enough balance.
>>>>
>>>
>>> Nack. I don't feel comfortable making scalability features of core code
>>> configurable.
>>
>> Out of respect, is this a general rule not making scalability features
>> of core code configurable?
> 
> I doubt its a rule, just common sense. Users have no business
> configuring such low level details. The optimizations need to
> transparently work for everyone.

There may sometimes be a good reason for making this kind of
thing configurable, but since there were no performance
numbers in the changelog, I have not seen any such reason for
this particular change :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
