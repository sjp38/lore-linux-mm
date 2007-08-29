Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7TMbEJu011822
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:37:14 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TMemww115162
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:40:48 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TMbEDT000720
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:37:14 +1000
Message-ID: <46D5F517.1080809@linux.vnet.ibm.com>
Date: Thu, 30 Aug 2007 04:07:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH] Memory controller improve user interface
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop> <1188413148.28903.113.camel@localhost>  <46D5ED5C.9030405@linux.vnet.ibm.com> <1188425894.28903.140.camel@localhost> <6599ad830708291520t2bc9ea20m2bdcd9e042b3a423@mail.gmail.com> <1188426352.28903.143.camel@localhost>
In-Reply-To: <1188426352.28903.143.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Wed, 2007-08-29 at 15:20 -0700, Paul Menage wrote:
>> I'd argue that having the user's specified limit be truncated to the
>> page size is less confusing than giving an EINVAL if it's not page
>> aligned.
> 
> Do we truncate mmap() values to the nearest page so to not confuse the
> user? ;)
> 

I think rounding to the closest page size is a better option, but
again it can be a bit confusing. I am all for using memparse() to
parse the user input as a specification of the memory limit.

The second question of how to store it internally without truncation/
rounding is something we need to agree upon. We also need to see
how to display the data back to the user.

I chose kilobytes for two reasons

1. Several people recommended it
2. Herbert mentioned that they've moved to that interface and it
   was working fine for them.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

PS: I am going off to the web to search for some CUI/CLI guidelines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
