Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iA2MYKLv252816
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 17:34:31 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iA2MYAAY098652
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 15:34:10 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iA2MYAQs004277
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 15:34:10 -0700
Message-ID: <41880B60.9070004@us.ibm.com>
Date: Tue, 02 Nov 2004 14:34:08 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
References: <4187FA6D.3070604@us.ibm.com>	<20041102220720.GV3571@dualathlon.random>	<4188086F.8010005@us.ibm.com> <20041102142944.0be6f750.akpm@osdl.org>
In-Reply-To: <20041102142944.0be6f750.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: andrea@novell.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Dave Hansen <haveblue@us.ibm.com> wrote:
> 
>>Andrea Arcangeli wrote:
>>
>>>Still I recommend investigating _why_ debug_pagealloc is violating the
>>>API. It might not be necessary to wait for the pageattr universal
>>>feature to make DEBUG_PAGEALLOC work safe.
>>
>>OK, good to know.  But, for now, can we pull this out of -mm?  Or, at 
>>least that BUG_ON()?  DEBUG_PAGEALLOC is an awfully powerful debugging 
>>tool to just be removed like this.
> 
> If we make it a WARN_ON, will that cause a complete storm of output?

Yeah, just tried it.  I hit a couple hundred of them before I got to init.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
