Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id CF5D76B0098
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 09:23:16 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so8882646pad.1
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 06:23:15 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id zo6si20254921pbc.13.2014.03.11.06.23.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 06:23:14 -0700 (PDT)
Message-ID: <531F0E39.9020100@oracle.com>
Date: Tue, 11 Mar 2014 09:23:05 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: bad rss-counter message in 3.14rc5
References: <20140305174503.GA16335@redhat.com> <20140305175725.GB16335@redhat.com> <20140307002210.GA26603@redhat.com> <20140311024906.GA9191@redhat.com> <20140310201340.81994295.akpm@linux-foundation.org> <20140310214612.3b4de36a.akpm@linux-foundation.org> <20140311045109.GB12551@redhat.com> <20140310220158.7e8b7f2a.akpm@linux-foundation.org> <20140311053017.GB14329@redhat.com> <20140311132024.GC32390@moon>
In-Reply-To: <20140311132024.GC32390@moon>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Dave Jones <davej@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On 03/11/2014 09:20 AM, Cyrill Gorcunov wrote:
> On Tue, Mar 11, 2014 at 01:30:17AM -0400, Dave Jones wrote:
>>   > >  >
>>   > >  > I don't see any holes in regular migration.  Do you know if this is
>>   > >  > reproducible with CONFIG_NUMA_BALANCING=n or CONFIG_NUMA=n?
>>   > >
>>   > > CONFIG_NUMA_BALANCING was n already btw, so I'll do a NUMA=n run.
>>   >
>>   > There probably isn't much point unless trinity is using
>>   > sys_move_pages().  Is it?  If so it would be interesting to disable
>>   > trinity's move_pages calls and see if it still fails.
>>
>> Ok, with move_pages excluded it still oopses.
>
> Dave, is it possible to somehow figure out was someone reading pagemap file
> at moment of the bug triggering?

We can sprinkle printk()s wherever might be useful, might not be 100% accurate but
should be close enough to confirm/deny the theory.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
