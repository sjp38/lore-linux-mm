Received: from shaolinmicro.com (star10.staff.shaolinmicro.com [192.168.0.10])
	by mail.shaolinmicro.com (8.11.6/linuxconf) with ESMTP id g5N8u0S27406
	for <linux-mm@kvack.org>; Sun, 23 Jun 2002 16:56:01 +0800
Message-ID: <3D158D1E.1090802@shaolinmicro.com>
Date: Sun, 23 Jun 2002 16:55:58 +0800
From: David Chow <davidchow@shaolinmicro.com>
MIME-Version: 1.0
Subject: Big memory, no struct page allocation
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dear all,

Hi, I've got a silly but serious question. I want to allocate a large 
buffer (>512MB) in kernel. Normally you use __get_free_page and handle 
it with page pointers. But when get to very large (say 1024MB), I will 
need to use 2 level of page pointer indirection to carry the page 
pointer array. I also find the total size of page struct is quite large 
when using lots of pages, what I want is to use memory pages without 
struct page, is this possible? By the way, can I use lots of memory in 
the kernel, something like 1GB of memory allocation when physically RAM 
available? Please give advise. Thanks.

regards,
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
