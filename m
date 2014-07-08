Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 17C9E6B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 11:26:21 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id 9so2302875ykp.20
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 08:26:20 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r48si14098083yho.59.2014.07.08.08.26.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 08:26:20 -0700 (PDT)
Message-ID: <53BC0D7D.9000207@oracle.com>
Date: Tue, 08 Jul 2014 11:25:49 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm/sched/net: BUG when running simple code
References: <539A6850.4090408@oracle.com> <20140708145147.GH6758@twins.programming.kicks-ass.net>
In-Reply-To: <20140708145147.GH6758@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 07/08/2014 10:51 AM, Peter Zijlstra wrote:
> On Thu, Jun 12, 2014 at 10:56:16PM -0400, Sasha Levin wrote:
>> Hi all,
>> 
>> Okay, I'm really lost. I got the following when fuzzing, and can't really explain what's going on. It seems that we get a "unable to handle kernel paging request" when running rather simple code, and I can't figure out how it would cause it.
>> 
> 
> Are you running on AMD hardware? If so; check out this thread:
> 
> http://marc.info/?i=53B02CEB.7010607@web.de
> 

Unfortunately (luckily?) it's all Intel over here.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
