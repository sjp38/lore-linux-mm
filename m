Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC5BA6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:01:03 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m21so14211292qkk.12
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:01:03 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id s185si5082632qkf.251.2018.04.24.13.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 13:01:02 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w3OJuPHk068931
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 20:01:01 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2hfvrbuv75-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 20:01:00 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w3OK0x9T003308
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 20:01:00 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w3OK0xNg013927
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 20:00:59 GMT
Received: by mail-ot0-f171.google.com with SMTP id j27-v6so22567904ota.5
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:00:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180420152922.21f43e52@gandalf.local.home>
References: <20180420191042.23452-1-pasha.tatashin@oracle.com> <20180420152922.21f43e52@gandalf.local.home>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 24 Apr 2018 16:00:11 -0400
Message-ID: <CAGM2reaqf4y4kb1jC+_vgG8mGRwaV_o75eMXTxWjZB3tWOM+KA@mail.gmail.com>
Subject: Re: [v1] mm: access to uninitialized struct page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

Hi Steven,

Thank you for your review:

>> https://lkml.org/lkml/2018/4/18/797
>
> #2, Do not use "lkml.org" it is a very unreliable source.
>

OK

> I'm fine with this change, but what happens if mm_init() traps?
>
> But that is probably not a case we really care about, as it is in the
> very early boot stage.


Yes, the assumption is that we do not trap in mm_init(), which I think
is the case because of early boot, and also I did not see this happen
during testing.

>
>>
>>       ftrace_init();
>>
>
> One thing I could add is to move ftrace_init() before trap_init(). But
> that may require some work, because it may still depend on trap_init()
> as well. But making ftrace_init() not depend on trap_init() is easier
> than making it not depend on ftrace_init(). Although it may require
> more arch updates.
>
> I'm not saying that you should move it, it's something that can be
> added later after this change is implemented.

This makes, sense, but should be done outside of this bug fix.

>
> Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
>

Thank you. I will send out an updated patch.

Pavel
