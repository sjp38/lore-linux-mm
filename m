Received: from m2hub.mail.wipro.com (m2hub.wipro.com [164.164.27.50])
	by wiprom2mx1.wipro.com (8.9.3+Sun/8.9.3) with ESMTP id PAA07501
	for <linux-mm@kvack.org>; Mon, 14 May 2001 15:24:01 GMT
Received: from m2vwall2.wipro.com ([164.164.27.52]) by
          m2hub.mail.wipro.com (Netscape Messaging Server 4.15) with SMTP
          id GDBK7N00.762 for <linux-mm@kvack.org>; Mon, 14 May 2001
          15:10:35 +0530
Date: Mon, 14 May 2001 15:19:54 +0530 (IST)
From: Kunaal Mahanti <kunaal.mahanti@wipro.com>
Subject: Re: kernel position
In-Reply-To: <20010514092219.55514.qmail@web13202.mail.yahoo.com>
Message-ID: <Pine.PTX.3.96.1010514150742.26385A-100000@wipro.wipsys.sequent.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Any Anderson <any_and@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2001, Any Anderson wrote:

Hi,
> I wann know where in the physical memory is kernel
> loaded by the loader (such as lilo) and does this
> position has any significance in mm system. If that

The kernel is loaded loaded beyond 0x1000000 (1MB), this is a h/w
constraint as most DMA devices cannot address beyond that, so we leave if
free, although there should'nt be any problem using a lower address for
kernel.

> location is to be changed which files should be
> changed. Lets assume we are talking for x86 platform.
> Thanks in advance for your time.

I think all we need is to use -Ttext flag while loading the kernel to
modify the load address. If I am correct the other things will fall in
place. mem_init() will take care of marking the remaining memory as
dynamic.
-

Kunaal Mahanti
Senior Software Engineer,
IBM NUMA-Q IDC,
Wipro Technologies.
Ph : +91-80-5732293/96 Ext: 5242
Fax: +91-80-5732296
-------------------------------------------------------------------------------
Visit us at http://www.wipro.com/ and http://www.wiproindia.com/ 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
