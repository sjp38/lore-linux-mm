Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8UFPWtW023261
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:25:32 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8UFPWon090166
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:25:32 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8UFPWIS000979
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:25:32 -0400
Subject: Re: [PATCH 05/07] i386: sparsemem on pc
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050930073258.10631.74982.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	 <20050930073258.10631.74982.sendpatchset@cherry.local>
Content-Type: text/plain
Date: Fri, 30 Sep 2005 08:25:29 -0700
Message-Id: <1128093929.6145.27.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-09-30 at 16:33 +0900, Magnus Damm wrote:
> This patch for enables and fixes sparsemem support on i386. This is the
> same patch that was sent to linux-kernel on September 6:th 2005, but this 
> patch includes up-porting to fit on top of the patches written by Dave Hansen.

I'll post a more comprehensive way to do this in just a moment.  

	Subject: memhotplug testing: hack for flat systems

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
