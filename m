Message-ID: <3D9B5E1D.2000301@us.ibm.com>
Date: Wed, 02 Oct 2002 13:59:09 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lse-tech] Re: VolanoMark Benchmark results for 2.5.26, 2.5.26
 + rmap, 2.5.35 + mm1, and 2.5.38 + mm3
References: <Pine.LNX.4.44L.0209172219200.1857-100000@imladris.surriel.com> <3D948EA6.A6EFC26B@austin.ibm.com> <3D94A43B.49C65AE8@digeo.com> <3D9B402D.601E52B6@austin.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Hartner <hartner@austin.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Bill Hartner wrote:
> Andrew Morton wrote:
> 
>>Bill Hartner wrote:
>>
>>>...
>>>2.5.35       44693  86.1 1.45        1,982,236 KB  5,393,152 KB  7,375,388 KB
>>>2.5.35mm1    39679  99.6 1.50       *2,720,600 KB *6,154,512 KB *8,875,112 KB
>>>
>>
>>2.5.35 was fairly wretched from the swapout point of view.
>>Would be interesting to retest on 2.5.38-mm/2.5.39 sometime.
>>
> 
> Here are VolanoMark results for 2.5.38 and 2.5.38-mm3 for both
> 3GB (memory pressure) and 4GB.  I will repeat for 2.5.40 mm1 or
> what ever is the latest and greatest on Friday.

Could you possibly include profiling data as well?  oprofile would be 
preferred, but readprofile would be fine if you can get it.  We can 
guess what is causing the degredation, but profiles will offer some 
hard proof.

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
