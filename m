Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7TMiJhi021644
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:44:19 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TMlqGC203364
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:47:52 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TMiIta028973
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:44:18 +1000
Message-ID: <46D5F6BF.2080607@linux.vnet.ibm.com>
Date: Thu, 30 Aug 2007 04:14:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH]  Memory controller improve user interface
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop> <1188413148.28903.113.camel@localhost>  <46D5ED5C.9030405@linux.vnet.ibm.com> <1188425894.28903.140.camel@localhost>  <46D5F2BB.8010203@linux.vnet.ibm.com> <1188427000.28903.148.camel@localhost>
In-Reply-To: <1188427000.28903.148.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Thu, 2007-08-30 at 03:57 +0530, Balbir Singh wrote:
>> True, mmap() is a good example of such an interface for developers, I
>> am not sure about system admins though.
>>
>> To quote Andrew
>> <quote>
>> Reporting tools could run getpagesize() and do the arithmetic, but we
>> generally try to avoid exposing PAGE_SIZE, HZ, etc to userspace in this
>> manner.
>> </quote>
> 
> Well, rounding to PAGE_SIZE exposes PAGE_SIZE as well, just in a
> non-intuitive fashion. :)
> 

Agreed, but the user might choose to ignore it altogether.

> If we're going to modify what the user specifies, we should probably at
> least mandate that writes are only a "suggestion" and users must read
> back the value to ensure what actually got committed.
> 

Agreed, excellent suggestion!

> If we're going to round in any direction, shouldn't we round up?  If a
> user specifies 4097 bytes and uses two pages, we don't want to complain
> when they hit that second page.  
> 

Absolutely, I used rounding to mean round up, truncation for rounding down.

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
