From: "M. Edward Borasky" <znmeb@aracnet.com>
Subject: RE: [PATCH] add vmalloc stats to meminfo
Date: Sun, 15 Sep 2002 10:44:12 -0700
Message-ID: <HBEHIIBBKKNOBLMPKCBBMEAFFGAA.znmeb@aracnet.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20020915172608.GJ3530@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'd still like a backport to the (Red Hat 7.3) 2.4.18 kernel if it is
possible. I'm a big fan of statistics and logging them.

M. Edward (Ed) Borasky
mailto: znmeb@borasky-research.net
http://www.pdxneurosemantics.com
http://www.meta-trading-coach.com
http://www.borasky-research.net

Coaching: It's Not Just for Athletes and Executives Any More!

-----Original Message-----
From: William Lee Irwin III [mailto:wli@holomorphy.com]
Sent: Sunday, September 15, 2002 10:26 AM
To: M. Edward (Ed) Borasky
Cc: Andrew Morton; Dave Hansen; Martin J. Bligh;
linux-kernel@vger.kernel.org; linux-mm@kvack.org
Subject: Re: [PATCH] add vmalloc stats to meminfo

On Sun, 15 Sep 2002, William Lee Irwin III wrote:
>> Also, dynamic vmalloc allocations may very well be starved by boot-time
>> allocations on systems where much vmallocspace is required for IO memory.
>> The failure mode of such is effectively deadlock, since they block
>> indefinitely waiting for permanent boot-time allocations to be freed up.

On Sun, Sep 15, 2002 at 10:23:24AM -0700, M. Edward (Ed) Borasky wrote:
> Thank you!! How difficult would it be to back-port this to 2.4.18?

Note the follow-up to this saying that the above paragraph was incorrect.
It doesn't sleep except to allocate backing memmory.


Bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
