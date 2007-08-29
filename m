Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TMIGZk031083
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:18:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TMIGdg477010
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:18:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TMIFvf008724
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 18:18:15 -0400
Subject: Re: [-mm PATCH]  Memory controller improve user interface
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <46D5ED5C.9030405@linux.vnet.ibm.com>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	 <1188413148.28903.113.camel@localhost>
	 <46D5ED5C.9030405@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Wed, 29 Aug 2007 15:18:14 -0700
Message-Id: <1188425894.28903.140.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-30 at 03:34 +0530, Balbir Singh wrote:
> I've thought about this before. The problem is that a user could
> set his limit to 10000 bytes, but would then see the usage and
> limit round to the closest page boundary. This can be confusing
> to a user. 

True, but we're lying if we allow a user to set their limit there,
because we can't actually enforce a limit at 8,192 bytes vs 10,000.
They're the same limit as far as the kernel is concerned.

Why not just -EINVAL if the value isn't page-aligned?  There are plenty
of interfaces in the kernel that require userspace to know the page
size, so this shouldn't be too difficult.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
