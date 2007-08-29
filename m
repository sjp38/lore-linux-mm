Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TMPsMC004381
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:25:54 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TMPsqw677526
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:25:54 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TMPr0X024590
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:25:54 -0400
Subject: Re: [-mm PATCH] Memory controller improve user interface
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <6599ad830708291520t2bc9ea20m2bdcd9e042b3a423@mail.gmail.com>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	 <1188413148.28903.113.camel@localhost>
	 <46D5ED5C.9030405@linux.vnet.ibm.com>
	 <1188425894.28903.140.camel@localhost>
	 <6599ad830708291520t2bc9ea20m2bdcd9e042b3a423@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 29 Aug 2007 15:25:52 -0700
Message-Id: <1188426352.28903.143.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-29 at 15:20 -0700, Paul Menage wrote:
> 
> I'd argue that having the user's specified limit be truncated to the
> page size is less confusing than giving an EINVAL if it's not page
> aligned.

Do we truncate mmap() values to the nearest page so to not confuse the
user? ;)

Imagine a careful application setting and accounting for limits on a
long-running system.  Might its internal accounting get sufficiently
misaligned from the kernel's after a while to cause a problem?
Truncating values like that would appear reserve significantly less
memory than desired over a long period of time.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
