Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7JGjQrk017750
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 02:45:26 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7JGjqxP4784292
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 02:45:52 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7JGjq8D021023
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 02:45:52 +1000
Message-ID: <48AAF8C0.1010806@linux.vnet.ibm.com>
Date: Tue, 19 Aug 2008 22:15:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [discuss] memrlimit - potential applications that can use
References: <48AA73B5.7010302@linux.vnet.ibm.com> <1219161525.23641.125.camel@nimitz>
In-Reply-To: <1219161525.23641.125.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Andrea Righi <righi.andrea@gmail.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2008-08-19 at 12:48 +0530, Balbir Singh wrote:
>> 1. To provide a soft landing mechanism for applications that exceed their memory
>> limit. Currently in the memory resource controller, we swap and on failure OOM.
>> 2. To provide a mechanism similar to memory overcommit for control groups.
>> Overcommit has finer accounting, we just account for virtual address space usage.
>> 3. Vserver will directly be able to port over on top of memrlimit (their address
>> space limitation feature)
> 
> Balbir,
> 
> This all seems like a little bit too much hand waving to me.  I don't

Dave, there is no hand waving, just an honest discussion. Although, you may not
see it in the background, we still need overcommit protection and we have it
enabled by default for the system. There are applications that can deal with the
constraints setup by the administrator and constraints of the environment,
please see http://en.wikipedia.org/wiki/Autonomic_computing.

> really see a single concrete user in the "potential applications" here.
> I really don't understand why you're pushing this so hard if you don't
> have anyone to actually use it.
> 
> I just don't see anyone that *needs* it.  There's a lot of "it would be
> nice", but no "needs".

If you see the original email, I've sent - I've mentioned that we need
overcommit support (either via memrlimit or by porting over the overcommit
feature) and the exploiters you are looking for is the same as the ones who need
overcommit and RLIMIT_AS support.

On the memory overcommit front, please see PostgreSQL Server Administrator's
Guide at
http://www.network-theory.co.uk/docs/postgresql/vol3/LinuxMemoryOvercommit.html

The guide discusses turning off memory overcommit so that the database is never
OOM killed, how do we provide these guarantees for a particular control group?
We can do it system wide, but ideally we want the control point to be per
control group.

As far as other users are concerned, I've listed users of the memory limit
feature, in the original email I sent out. To try and understand your viewpoint
better, could you please tell me if

1. You are opposed to overcommit and RLIMIT_AS as features

OR

2. Expanding them to control groups

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
