Date: Sun, 15 Sep 2002 07:50:19 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] add vmalloc stats to meminfo
Message-ID: <73286230.1032076218@[10.10.2.3]>
In-Reply-To: <3D84340A.25ED4C69@digeo.com>
References: <3D84340A.25ED4C69@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Some workloads like to eat up a lot of vmalloc space.
> 
> Which workloads are those?
> 
>>  It is often hard to tell
>> whether this is because the area is too small, or just too fragmented.  This
>> makes it easy to determine.
> 
> I do not recall ever having seen any bug/problem reports which this patch
> would have helped to solve.  Could you explain in more detai why is it useful?

Seen on specweb - doubling the size of the vmalloc space made it go
away, but without any counters, it was all really just guesswork.

I am also going to implement per-node slabcache on top of vmalloc,
as slabs have to be in permanently mapped KVA, but all ZONE_NORMAL
is on node 0. That's going to put a lot of pressure on the vmalloc
area.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
