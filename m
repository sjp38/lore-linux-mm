Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iA32mLLv503494
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 21:48:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iA32mCF9120018
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 19:48:12 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iA32mBKD019637
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 19:48:11 -0700
Message-ID: <418846E9.1060906@us.ibm.com>
Date: Tue, 02 Nov 2004 18:48:09 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
References: <4187FA6D.3070604@us.ibm.com> <20041102220720.GV3571@dualathlon.random> <41880E0A.3000805@us.ibm.com> <4188118A.5050300@us.ibm.com> <20041103013511.GC3571@dualathlon.random> <418837D1.402@us.ibm.com> <20041103022606.GI3571@dualathlon.random>
In-Reply-To: <20041103022606.GI3571@dualathlon.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Tue, Nov 02, 2004 at 05:43:45PM -0800, Dave Hansen wrote:
> 
>>Oh, crap.  I meant to clear ->mapped when change_attr(__pgprot(0)) was 
>>done on it, and set it when it was changed back.  Doing that correctly 
>>preserves the symmetry, right?
> 
> yes it should. I agree with Andrew a bitflag would be enough. I'd call
> it PG_prot_none.

It should be enough, but I don't think we want to waste a bitflag for 
something that's only needed for debugging anyway.  They're getting 
precious these days.  Might as well just bloat the kernel some more when 
the alloc debugging is on.

I'll see what I can do to get some backtraces of the __pg_prot(0) &&
page->mapped cases.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
