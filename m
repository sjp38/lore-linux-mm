Date: Sun, 15 Sep 2002 00:11:57 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] add vmalloc stats to meminfo
Message-ID: <20020915071157.GH3530@holomorphy.com>
References: <3D8422BB.5070104@us.ibm.com> <3D84340A.25ED4C69@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D84340A.25ED4C69@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
>>  It is often hard to tell
>> whether this is because the area is too small, or just too fragmented.  This
>> makes it easy to determine.

On Sun, Sep 15, 2002 at 12:17:30AM -0700, Andrew Morton wrote:
> I do not recall ever having seen any bug/problem reports which this patch
> would have helped to solve.  Could you explain in more detai why is it useful?

LDT's were formerly allocated in vmallocspace. This presented difficulties
with many simultaneous threaded applications. Also, given that there is
zero vmallocspace OOM recovery now present in the kernel some method of
monitoring this aspect of system behavior up until the point of failure is
useful for detecting further problem areas (LDT's were addressed by using
non-vmalloc allocations).

Also, dynamic vmalloc allocations may very well be starved by boot-time
allocations on systems where much vmallocspace is required for IO memory.
The failure mode of such is effectively deadlock, since they block
indefinitely waiting for permanent boot-time allocations to be freed up.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
