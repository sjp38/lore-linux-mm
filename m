Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3AItlwm010000
	for <linux-mm@kvack.org>; Mon, 10 Apr 2006 14:55:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3AIx36e152824
	for <linux-mm@kvack.org>; Mon, 10 Apr 2006 12:59:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k3AItlqm006407
	for <linux-mm@kvack.org>; Mon, 10 Apr 2006 12:55:47 -0600
Subject: Re: [RFC/PATCH] Shared Page Tables [1/2]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1144685591.570.36.camel@wildcat.int.mccr.org>
References: <1144685591.570.36.camel@wildcat.int.mccr.org>
Content-Type: text/plain
Date: Mon, 10 Apr 2006 11:54:56 -0700
Message-Id: <1144695296.31255.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-04-10 at 11:13 -0500, Dave McCracken wrote:
> Complete the macro definitions for pxd_page/pxd_page_kernel 

Could you explain a bit why these are needed for shared page tables?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
