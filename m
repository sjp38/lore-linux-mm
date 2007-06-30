Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5U2HaeF061312
	for <linux-mm@kvack.org>; Sat, 30 Jun 2007 02:17:36 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5U2Ha1J2052190
	for <linux-mm@kvack.org>; Sat, 30 Jun 2007 04:17:36 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5U2HaKK003420
	for <linux-mm@kvack.org>; Sat, 30 Jun 2007 04:17:36 +0200
Message-ID: <4685D9C9.20504@de.ibm.com>
Date: Sat, 30 Jun 2007 06:19:21 +0200
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: RFC: multiple address spaces for one process
References: <87myynt1m6.wl%peter@chubb.wattle.id.au> <468517E1.4050803@goop.org>
In-Reply-To: <468517E1.4050803@goop.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, avi Kivity <avi@qumranet.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> It might be interesting if the two cases could be unified in some way, 
> so that the VMMs could use a common usermode mechanism to achieve the 
> same end, which is what Carsten was proposing.  But its not obvious to 
> me how much common mechanism can be pulled out, since its a pretty 
> deeply architecture-specific operation.
The big difference here is that LinuxOnLinux does represent guest 
virtual addressing in these mm structs where all other kernel based 
VMMs do represent guest physical in the user address space. That 
somewhat disqualifies LinuxOnLinux to share the commonality.
Whether or not proposed patch makes sense for shaddow page tables is 
unknown to me, since we have nested paging on s390.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
