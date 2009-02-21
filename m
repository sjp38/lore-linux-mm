Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 82E2D6B003D
	for <linux-mm@kvack.org>; Fri, 20 Feb 2009 23:36:04 -0500 (EST)
Received: from unknown (HELO [192.168.14.27]) (viral.mehta@[192.168.14.27])
          (envelope-sender <viral.mehta@einfochips.com>)
          by ahmedabad.einfochips.com (qmail-ldap-1.03) with SMTP
          for <linux-mm@kvack.org>; 21 Feb 2009 04:30:21 -0000
Message-ID: <499F8300.1020300@einfochips.com>
Date: Sat, 21 Feb 2009 09:58:48 +0530
From: Viral Mehta <viral.mehta@einfochips.com>
MIME-Version: 1.0
Subject: kmap problem
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,
I am writing a kernel module. And I am facing a problem relate to Kmap.

I am retriving Kernel Virtual Address for a specific Page using kmap() 
and then after some time I am doing kunmap().
Now, I know that kmap can give A LIMITED NUMBER OF MAPPINGS and so such 
mapping should NOT be held longer. But in my case it is absolutely 
necessary to hold more than 1024 such mappings.

The same code is NOT working on 2.6.10 kernel and IS WORKING on 2.6.18 
kernel. The system is same and there are two kernels that I am playing 
with.

My only question is what is so changed in 2.6.18 kernel from 2.6.10 that 
the same code is working and evidently kmap can hold more than 1024 
virtual address mappings.

The other thing I would like to know if there is ANY generic way to 
handle this situation in 2.6.10 kernel.

Thanks,
Viral
-- 
_____________________________________________________________________
Disclaimer: This e-mail message and all attachments transmitted with it
are intended solely for the use of the addressee and may contain legally
privileged and confidential information. If the reader of this message
is not the intended recipient, or an employee or agent responsible for
delivering this message to the intended recipient, you are hereby
notified that any dissemination, distribution, copying, or other use of
this message or its attachments is strictly prohibited. If you have
received this message in error, please notify the sender immediately by
replying to this message and please delete it from your computer. Any
views expressed in this message are those of the individual sender
unless otherwise stated.Company has taken enough precautions to prevent
the spread of viruses. However the company accepts no liability for any
damage caused by any virus transmitted by this email.
__________________________________________________________________________
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
