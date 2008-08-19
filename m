Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7JFwpg9020624
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 11:58:51 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7JFwoMC2170990
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 11:58:50 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7JFwk0e000361
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 09:58:46 -0600
Subject: Re: [discuss] memrlimit - potential applications that can use
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48AA73B5.7010302@linux.vnet.ibm.com>
References: <48AA73B5.7010302@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Tue, 19 Aug 2008 08:58:44 -0700
Message-Id: <1219161525.23641.125.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Andrea Righi <righi.andrea@gmail.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-19 at 12:48 +0530, Balbir Singh wrote:
> 1. To provide a soft landing mechanism for applications that exceed their memory
> limit. Currently in the memory resource controller, we swap and on failure OOM.
> 2. To provide a mechanism similar to memory overcommit for control groups.
> Overcommit has finer accounting, we just account for virtual address space usage.
> 3. Vserver will directly be able to port over on top of memrlimit (their address
> space limitation feature)

Balbir,

This all seems like a little bit too much hand waving to me.  I don't
really see a single concrete user in the "potential applications" here.
I really don't understand why you're pushing this so hard if you don't
have anyone to actually use it.

I just don't see anyone that *needs* it.  There's a lot of "it would be
nice", but no "needs".

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
