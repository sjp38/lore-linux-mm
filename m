Date: Tue, 18 Apr 2000 10:18:01 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: preemp / nonpreemp
Message-ID: <20000418101801.I3916@redhat.com>
References: <CA2568C5.0017E931.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568C5.0017E931.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Tue, Apr 18, 2000 at 09:42:27AM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 18, 2000 at 09:42:27AM +0530, pnilesh@in.ibm.com wrote:
> The Linux kernel is preemptable.

Not by any normal definition.  The kernel is not preempted: any
scheduler interrupt which occurs while kernel code is running will
not cause a reschedule.

Kernel code _can_ be rescheduled, but only explicitly by calling
schedule(), or implicitly by calling some function which performs
a sleeping operation (including page faults).
> 
> Does the preemption mean that inside system calls in kernel a call to
> schedule is possible .

It is possible, yes, but it will not happen in a preemptive manner.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
