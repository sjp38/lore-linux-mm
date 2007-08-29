Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7TMRJ0S001292
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:27:19 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TMUpcV203478
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:30:51 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TMRH2I018657
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:27:17 +1000
Message-ID: <46D5F2BB.8010203@linux.vnet.ibm.com>
Date: Thu, 30 Aug 2007 03:57:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH]  Memory controller improve user interface
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop> <1188413148.28903.113.camel@localhost>  <46D5ED5C.9030405@linux.vnet.ibm.com> <1188425894.28903.140.camel@localhost>
In-Reply-To: <1188425894.28903.140.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Thu, 2007-08-30 at 03:34 +0530, Balbir Singh wrote:
>> I've thought about this before. The problem is that a user could
>> set his limit to 10000 bytes, but would then see the usage and
>> limit round to the closest page boundary. This can be confusing
>> to a user. 
> 
> True, but we're lying if we allow a user to set their limit there,
> because we can't actually enforce a limit at 8,192 bytes vs 10,000.
> They're the same limit as far as the kernel is concerned.
> 
> Why not just -EINVAL if the value isn't page-aligned?  There are plenty
> of interfaces in the kernel that require userspace to know the page
> size, so this shouldn't be too difficult.

True, mmap() is a good example of such an interface for developers, I
am not sure about system admins though.

To quote Andrew
<quote>
Reporting tools could run getpagesize() and do the arithmetic, but we
generally try to avoid exposing PAGE_SIZE, HZ, etc to userspace in this
manner.
</quote>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
