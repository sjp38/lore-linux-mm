Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 730726B0202
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 08:43:34 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o3QChTQx005459
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 12:43:29 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3QChUlv876680
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 13:43:30 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3QChTZF009980
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 13:43:29 +0100
Message-ID: <4BD58A6C.6040104@linux.vnet.ibm.com>
Date: Mon, 26 Apr 2010 14:43:24 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: Subject: [PATCH][RFC] mm: make working set portion that is protected
 tunable v2
References: <20100322235053.GD9590@csn.ul.ie> <20100419214412.GB5336@cmpxchg.org>	 <4BCD55DA.2020000@linux.vnet.ibm.com> <20100420153202.GC5336@cmpxchg.org> <4BCDE2F0.3010009@redhat.com> <4BCE7DD1.70900@linux.vnet.ibm.com>	 <4BCEAAC6.7070602@linux.vnet.ibm.com> <4BCEFB4C.1070206@redhat.com>	 <4BCFEAD0.4010708@linux.vnet.ibm.com> <4BD57213.7060207@linux.vnet.ibm.com> <p2y2f11576a1004260459jcaf79962p50e4d29f990019ee@mail.gmail.com>
In-Reply-To: <p2y2f11576a1004260459jcaf79962p50e4d29f990019ee@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, gregkh@novell.com, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>



KOSAKI Motohiro wrote:
> Hi
> 
> I've quick reviewed your patch. but unfortunately I can't write my
> reviewed-by sign.

Not a problem, atm I'm happy about any review and comment :-)

>> Subject: [PATCH][RFC] mm: make working set portion that is protected tunable v2
>> From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
>>
>> *updates in v2*
>> - use do_div
>>
>> This patch creates a knob to help users that have workloads suffering from the
>> fix 1:1 active inactive ratio brought into the kernel by "56e49d21 vmscan:
>> evict use-once pages first".
>> It also provides the tuning mechanisms for other users that want an even bigger
>> working set to be protected.
> 
> We certainly need no knob. because typical desktop users use various
> application,
> various workload. then, the knob doesn't help them.

Briefly - We had discussed non desktop scenarios where like a day load 
that builds up the working set to 50% and a nightly backup job which 
then is unable to use that protected 50% when sequentially reading a lot 
of disks and due to that doesn't finish before morning.

The knob should help those people that know their system would suffer 
from this or similar cases to e.g. set the protected ratio smaller or 
even to zero if wanted.

As mentioned before, being able to gain back those protected 50% would 
be even better - if it can be done in a way not hurting the original 
intention of protecting them.

I personally just don't feel too good knowing that 50% of my memory 
might hang around unused for many hours while they could be of some use.
I absolutely agree with the old intention and see how the patch helped 
with the latency issue Elladan brought up in the past - but it just 
looks way too aggressive to protect it "forever" for some server use cases.

> Probably, I've missed previous discussion. I'm going to find your previous mail.

The discussion ends at http://lkml.org/lkml/2010/4/22/38 - feel free to 
click through it.

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
