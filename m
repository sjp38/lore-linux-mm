Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TMagEm022634
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:36:42 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TMagFF555510
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:36:42 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TMagYo013834
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:36:42 -0400
Subject: Re: [-mm PATCH]  Memory controller improve user interface
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <46D5F2BB.8010203@linux.vnet.ibm.com>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	 <1188413148.28903.113.camel@localhost>
	 <46D5ED5C.9030405@linux.vnet.ibm.com>
	 <1188425894.28903.140.camel@localhost>
	 <46D5F2BB.8010203@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Wed, 29 Aug 2007 15:36:40 -0700
Message-Id: <1188427000.28903.148.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-30 at 03:57 +0530, Balbir Singh wrote:
> True, mmap() is a good example of such an interface for developers, I
> am not sure about system admins though.
> 
> To quote Andrew
> <quote>
> Reporting tools could run getpagesize() and do the arithmetic, but we
> generally try to avoid exposing PAGE_SIZE, HZ, etc to userspace in this
> manner.
> </quote>

Well, rounding to PAGE_SIZE exposes PAGE_SIZE as well, just in a
non-intuitive fashion. :)

If we're going to modify what the user specifies, we should probably at
least mandate that writes are only a "suggestion" and users must read
back the value to ensure what actually got committed.

If we're going to round in any direction, shouldn't we round up?  If a
user specifies 4097 bytes and uses two pages, we don't want to complain
when they hit that second page.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
