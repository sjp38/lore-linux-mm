Received: from wip-ec-wd.wipro.com (localhost.wipro.com [127.0.0.1])
	by localhost (Postfix) with ESMTP id 5923720609
	for <linux-mm@kvack.org>; Fri, 16 Jun 2006 17:07:45 +0530 (IST)
Received: from blr-ec-bh02.wipro.com (blr-ec-bh02.wipro.com [10.201.50.92])
	by wip-ec-wd.wipro.com (Postfix) with ESMTP id 45844205DE
	for <linux-mm@kvack.org>; Fri, 16 Jun 2006 17:07:45 +0530 (IST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: Memory Leak Detection and Kernel Memory monitoring tool
Date: Fri, 16 Jun 2006 17:09:49 +0530
Message-ID: <05B7784238A51247A0A9FB4B348CECAE01D768E5@PNE-HJN-MBX01.wipro.com>
From: <kaustav.majumdar@wipro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


-----Original Message-----
From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of Pekka
Enberg
Sent: Friday, June 16, 2006 4:50 PM
To: Kaustav Majumdar (WT01 - Semiconductors & Consumer Electronics)
Cc: linux-mm@kvack.org
Subject: Re: Memory Leak Detection and Kernel Memory monitoring tool

On 6/16/06, kaustav.majumdar@wipro.com <kaustav.majumdar@wipro.com>
wrote:
>> Please suggest other feasible ways of detecting leaks and monitoring
kernel memory
>> utilization.

>Well, there's CONFIG_DEBUG_SLAB_LEAK starting with 2.6.16, I think.

Actually I was trying for 2.6.15.4.

Regards,
Kaustav

                                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
