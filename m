Date: Thu, 24 Oct 2002 07:22:56 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <2832683854.1035444175@[10.10.2.3]>
In-Reply-To: <Pine.LNX.3.96.1021024064536.14473B-100000@gatekeeper.tmr.com>
References: <Pine.LNX.3.96.1021024064536.14473B-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Another thought, how does this play with NUMA systems? I don't have the
> problem, but presumably there are implications.

At some point we'll probably only want one shared set per node.
Gets tricky when you migrate processes across nodes though - will
need more thought

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
