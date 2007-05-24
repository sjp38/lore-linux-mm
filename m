Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4OCjVBC032258
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:45:31 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4OCjVf6498542
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:45:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4OCjVZG000482
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:45:31 -0400
Received: from [9.53.41.190] (kleikamp.austin.ibm.com [9.53.41.190])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l4OCjURS000466
	for <linux-mm@kvack.org>; Thu, 24 May 2007 08:45:31 -0400
Subject: Re: [RFC:PATCH 000/012] VM File Tails
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
References: <20070524121130.13533.32563.sendpatchset@kleikamp.austin.ibm.com>
Content-Type: text/plain
Date: Thu, 24 May 2007 07:45:30 -0500
Message-Id: <1180010730.11124.4.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-24 at 08:11 -0400, Dave Kleikamp wrote:
> I wanted to get some feedback on this as it is, before it undergoes some
> major re-writing.  These patches are against linux-2.6.22-rc2.
> 
> These patches implement what I'm calling "VM File Tails"

I mistyped the original subject.  The patches are also available here:
ftp://kernel.org/pub/linux/kernel/people/shaggy/vm_file_tails/

Thanks,
Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
