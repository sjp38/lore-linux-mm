Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2A95D6B00A4
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 10:58:52 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wm4so8557678obc.3
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 07:58:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id iz10si24522770obb.13.2014.03.11.07.58.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 07:58:51 -0700 (PDT)
Message-ID: <531F24A6.2020409@oracle.com>
Date: Tue, 11 Mar 2014 10:58:46 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: bad rss-counter message in 3.14rc5
References: <20140311024906.GA9191@redhat.com> <20140310201340.81994295.akpm@linux-foundation.org> <20140310214612.3b4de36a.akpm@linux-foundation.org> <20140311045109.GB12551@redhat.com> <20140310220158.7e8b7f2a.akpm@linux-foundation.org> <20140311053017.GB14329@redhat.com> <20140311132024.GC32390@moon> <531F0E39.9020100@oracle.com> <20140311134158.GD32390@moon> <20140311142817.GA26517@redhat.com> <20140311143750.GE32390@moon>
In-Reply-To: <20140311143750.GE32390@moon>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Dave Jones <davej@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On 03/11/2014 10:37 AM, Cyrill Gorcunov wrote:
> On Tue, Mar 11, 2014 at 10:28:17AM -0400, Dave Jones wrote:
>> On Tue, Mar 11, 2014 at 05:41:58PM +0400, Cyrill Gorcunov wrote:
>>   > On Tue, Mar 11, 2014 at 09:23:05AM -0400, Sasha Levin wrote:
>>   > > >>
>>   > > >>Ok, with move_pages excluded it still oopses.
>>   > > >
>>   > > >Dave, is it possible to somehow figure out was someone reading pagemap file
>>   > > >at moment of the bug triggering?
>>   > >
>>   > > We can sprinkle printk()s wherever might be useful, might not be 100% accurate but
>>   > > should be close enough to confirm/deny the theory.
>>   >
>>   > After reading some more, I suppose the idea I had is wrong, investigating.
>>   > Will ping if I find something.
>>
>> I can rule it out anyway, I can reproduce this by telling trinity to do nothing
>> other than mmap()'s.   I'll try and narrow down the exact parameters.
>
> Dave, iirc trinity can write log file pointing which exactly syscall sequence
> was passed, right? Share it too please.

I've sent one of those last time I reported this issue:

	https://lkml.org/lkml/2014/1/22/625


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
