Date: Thu, 24 Oct 2002 07:51:46 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <2834413140.1035445904@[10.10.2.3]>
In-Reply-To: <9100000.1035470286@baldur.austin.ibm.com>
References: <9100000.1035470286@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, Bill Davidsen <davidsen@tmr.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>> Another thought, how does this play with NUMA systems? I don't have the
>>> problem, but presumably there are implications.
>> 
>> At some point we'll probably only want one shared set per node.
>> Gets tricky when you migrate processes across nodes though - will
>> need more thought
> 
> Page tables can only be shared when they're pointing to the same 
> data pages anyway, so I think it's just part of the larger problem 
> of node-local memory.

Yes, same problem as text replication. You're right, it's probably not 
worth solving otherwise - too small a percentage of the real problem.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
