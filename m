Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5303828027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:51:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so5023762wmg.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:51:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bc3si1969152wjb.53.2016.09.27.04.51.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 04:51:05 -0700 (PDT)
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
References: <20160922152831.24165-1-vbabka@suse.cz>
 <006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
 <20160923172434.7ad8f2e0@roar.ozlabs.ibm.com> <57E55CBB.5060309@akamai.com>
 <5014387d-43da-03f6-a74b-2dc4fbf4fe32@suse.cz>
 <20160927212458.3ab42b41@roar.ozlabs.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010A97D@AcuExch.aculab.com>
 <20160927214229.2b0b49ac@roar.ozlabs.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <92d1ec2c-3246-bd1f-eae5-53ca425ab315@suse.cz>
Date: Tue, 27 Sep 2016 13:51:03 +0200
MIME-Version: 1.0
In-Reply-To: <20160927214229.2b0b49ac@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, David Laight <David.Laight@ACULAB.COM>
Cc: Jason Baron <jbaron@akamai.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Michal Hocko' <mhocko@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>

On 09/27/2016 01:42 PM, Nicholas Piggin wrote:
> On Tue, 27 Sep 2016 11:37:24 +0000
> David Laight <David.Laight@ACULAB.COM> wrote:
>
>> From: Nicholas Piggin
>> > Sent: 27 September 2016 12:25
>> > On Tue, 27 Sep 2016 10:44:04 +0200
>> > Vlastimil Babka <vbabka@suse.cz> wrote:
>> >
>> >
>> > What's your customer doing with those selects? If they care at all about
>> > performance, I doubt they want select to attempt order-4 allocations, fail,
>> > then use vmalloc :)
>>
>> If they care about performance they shouldn't be passing select() lists that
>> are anywhere near that large.
>> If the number of actual fd is small - use poll().
>
> Right. Presumably it's some old app they're still using, no?

Process name suggests it's part of db2 database. It seems it has to implement 
its own interface to select() syscall, because glibc itself seems to have a 
FD_SETSIZE limit of 1024, which is probably why this wasn't an issue for all the 
years...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
