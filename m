Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m63BMYIU017017
	for <linux-mm@kvack.org>; Thu, 3 Jul 2008 16:52:34 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m63BLIhh852158
	for <linux-mm@kvack.org>; Thu, 3 Jul 2008 16:51:18 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m63BMXCs029754
	for <linux-mm@kvack.org>; Thu, 3 Jul 2008 16:52:33 +0530
Date: Thu, 3 Jul 2008 16:52:33 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [BUILD-FAILURE] 2.6.26-rc8-mm1 - build failure at drivers/char/hvc_rtas.c
Message-ID: <20080703112233.GA6451@linux.vnet.ibm.com>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20080703020236.adaa51fa.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-testers@vger.kernel.org, rusty@rustcorp.com.au, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

2.6.26-rc8-mm1 kernel build fail on the powerpc, 

In file included from drivers/char/hvc_rtas.c:39:
drivers/char/hvc_console.h:59: error: field a??krefa?? has incomplete type
make[2]: *** [drivers/char/hvc_rtas.o] Error 1
make[1]: *** [drivers/char] Error 2
make: *** [drivers] Error 2

this was already fixed by rusty (http://lkml.org/lkml/2008/6/27/21).

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
