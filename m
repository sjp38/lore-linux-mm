Date: Wed, 02 Oct 2002 15:04:26 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: NUMA is bust with CONFIG_PREEMPT=y
Message-ID: <389320000.1033596266@flay>
In-Reply-To: <1033596139.27343.14.camel@phantasy>
References: <3D9B6939.397DB9EA@digeo.com>  <384860000.1033595383@flay> <1033596139.27343.14.camel@phantasy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Andrew Morton <akpm@digeo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> I'd favour the latter. It doesn't seem that useful on big machines like this,
>> and adds significant complication ... anyone really want it on a NUMA box? If
>> not, I'll make a patch to disable it for NUMA machines ...
> 
> I am not one of the 12 people in the world with a NUMA-Q, but I would
> not like to see you disable kernel preemption.

What does it buy you on a large NUMA box over the low-latency patches?

> Besides, why screw yourself over from the day when preemption is a
> requirement? </semi-kidding> ;-)

A scary thought ....

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
