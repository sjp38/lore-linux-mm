Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id A06D06B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 00:28:56 -0400 (EDT)
Received: by qcbgy10 with SMTP id gy10so63525044qcb.3
        for <linux-mm@kvack.org>; Sun, 10 May 2015 21:28:56 -0700 (PDT)
Received: from mail-qk0-x235.google.com (mail-qk0-x235.google.com. [2607:f8b0:400d:c09::235])
        by mx.google.com with ESMTPS id 77si11964978qhv.113.2015.05.10.21.28.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 May 2015 21:28:54 -0700 (PDT)
Received: by qku63 with SMTP id 63so80043138qku.3
        for <linux-mm@kvack.org>; Sun, 10 May 2015 21:28:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150508152513.GB28439@htj.duckdns.org>
References: <20150507064557.GA26928@july>
	<20150507154212.GA12245@htj.duckdns.org>
	<CAH9JG2UAVRgX0Mg0d7WgG0URpkgu4q_bbNMXyOOEh9WFPztppQ@mail.gmail.com>
	<20150508152513.GB28439@htj.duckdns.org>
Date: Mon, 11 May 2015 13:28:54 +0900
Message-ID: <CAH9JG2VROCekWCAa+1t6Giy2wHC171TD-AXQVxG2vTH-LPcoPA@mail.gmail.com>
Subject: Re: [RFC PATCH] PM, freezer: Don't thaw when it's intended frozen processes
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "\\Rafael J. Wysocki\\" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>

On Sat, May 9, 2015 at 12:25 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Kyungmin.
>
> On Fri, May 08, 2015 at 09:04:26AM +0900, Kyungmin Park wrote:
>> > I need to think more about it but as an *optimization* we can add
>> > freezing() test before actually waking tasks up during resume, but can
>> > you please clarify what you're seeing?
>>
>> The mobile application has life cycle and one of them is 'suspend'
>> state. it's different from 'pause' or 'background'.
>> if there are some application and enter go 'suspend' state. all
>> behaviors are stopped and can't do anything. right it's suspended. but
>> after system suspend & resume, these application is thawed and
>> running. even though system know it's suspended.
>>
>> We made some test application, print out some message within infinite
>> loop. when it goes 'suspend' state. nothing is print out. but after
>> system suspend & resume, it prints out again. that's not desired
>> behavior. and want to address it.
>>
>> frozen user processes should be remained as frozen while system
>> suspend & resume.
>
> Yes, they should and I'm not sure why what you're saying is happening
> because freezing() test done from the frozen tasks themselves should
> keep them in the freezer.  Which kernel version did you test?  Can you
> please verify it against a recent kernel?

The kernel 3.10 is not working as expected, but right the latest
kernel is working correctly.

I see I'll check what's different and which are modified.

Thank you,
Kyungmin Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
