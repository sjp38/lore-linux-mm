Date: Thu, 24 Oct 2002 09:38:06 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <9100000.1035470286@baldur.austin.ibm.com>
In-Reply-To: <2832683854.1035444175@[10.10.2.3]>
References: <Pine.LNX.3.96.1021024064536.14473B-100000@gatekeeper.tmr.com>
 <2832683854.1035444175@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Bill Davidsen <davidsen@tmr.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Thursday, October 24, 2002 07:22:56 -0700 "Martin J. Bligh"
<mbligh@aracnet.com> wrote:

>> Another thought, how does this play with NUMA systems? I don't have the
>> problem, but presumably there are implications.
> 
> At some point we'll probably only want one shared set per node.
> Gets tricky when you migrate processes across nodes though - will
> need more thought

Page tables can only be shared when they're pointing to the same data pages
anyway, so I think it's just part of the larger problem of node-local
memory.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
