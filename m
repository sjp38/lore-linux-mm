Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iA2MLmJ8382662
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 17:21:58 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iA2MLcF9083964
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 15:21:38 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iA2MLbqf029444
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 15:21:37 -0700
Message-ID: <4188086F.8010005@us.ibm.com>
Date: Tue, 02 Nov 2004 14:21:35 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
References: <4187FA6D.3070604@us.ibm.com> <20041102220720.GV3571@dualathlon.random>
In-Reply-To: <20041102220720.GV3571@dualathlon.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> Still I recommend investigating _why_ debug_pagealloc is violating the
> API. It might not be necessary to wait for the pageattr universal
> feature to make DEBUG_PAGEALLOC work safe.

OK, good to know.  But, for now, can we pull this out of -mm?  Or, at 
least that BUG_ON()?  DEBUG_PAGEALLOC is an awfully powerful debugging 
tool to just be removed like this.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
