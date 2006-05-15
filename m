Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4FELZM0002935
	for <linux-mm@kvack.org>; Mon, 15 May 2006 10:21:35 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4FELZml200110
	for <linux-mm@kvack.org>; Mon, 15 May 2006 10:21:35 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k4FELZWM011388
	for <linux-mm@kvack.org>; Mon, 15 May 2006 10:21:35 -0400
Subject: Re: [RFC] Hugetlb demotion for x86
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1147363859.24029.134.camel@localhost.localdomain>
References: <1147287400.24029.81.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0605101633140.7639@schroedinger.engr.sgi.com>
	 <1147363859.24029.134.camel@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 15 May 2006 07:20:17 -0700
Message-Id: <1147702817.6623.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Christoph Lameter <christoph@engr.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-05-11 at 11:10 -0500, Adam Litke wrote:
> Yes, the SIGBUS issues are "fixed".  Now the application is killed
> directly via VM_FAULT_OOM so it is not possible to handle the fault from
> userspace.  For my libhugetlbfs-based fallback approach, I needed to
> patch the kernel so that SIGBUS was delivered to the process like in the
> days of old.

Maybe this could be off-by-default behavior that can be enabled with a
special mmap flag or madvise, or something similar.  It seems that apps
don't want to get SIGBUS for low memory.  But, if they have _asked_ for
it, perhaps they'd be a bit more willing.

(BTW, I fixed the bogus linux-mm cc, finally ;)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
