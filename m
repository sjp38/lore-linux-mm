Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 0F3FA6B005C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 02:16:31 -0400 (EDT)
Message-ID: <4FEAA4AA.3000406@intel.com>
Date: Wed, 27 Jun 2012 14:14:02 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com> <4FEA9FDD.6030102@kernel.org>
In-Reply-To: <4FEA9FDD.6030102@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/27/2012 01:53 PM, Minchan Kim wrote:

> On 06/26/2012 01:14 AM, Seth Jennings wrote:
> 
>> This patch adds support for a local_tlb_flush_kernel_range()
>> function for the x86 arch.  This function allows for CPU-local
>> TLB flushing, potentially using invlpg for single entry flushing,
>> using an arch independent function name.
>>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> 
> Anyway, we don't matter INVLPG_BREAK_EVEN_PAGES's optimization point is 8 or something.


Different CPU type has different balance point on the invlpg replacing
flush all. and some CPU never get benefit from invlpg, So, it's better
to use different value for different CPU, not a fixed
INVLPG_BREAK_EVEN_PAGES.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
