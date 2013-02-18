Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 7763A6B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 13:09:32 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 18 Feb 2013 13:09:31 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id CEAC26E801A
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 13:09:26 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1II9RWk332134
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 13:09:28 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1IIAhCG026600
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 11:10:44 -0700
Message-ID: <51226E0B.5080000@linux.vnet.ibm.com>
Date: Mon, 18 Feb 2013 12:08:11 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] zsmalloc: Add Kconfig for enabling PTE method
References: <1360117028-5625-1-git-send-email-minchan@kernel.org> <51207655.5000209@gmail.com>
In-Reply-To: <51207655.5000209@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On 02/17/2013 12:19 AM, Ric Mason wrote:
> On 02/06/2013 10:17 AM, Minchan Kim wrote:
>> Zsmalloc has two methods 1) copy-based and 2) pte-based to access
>> allocations that span two pages. You can see history why we supported
>> two approach from [1].
>>
>> In summary, copy-based method is 3 times fater in x86 while pte-based
>> is 6 times faster in ARM.
> 
> Why in some arches copy-based method is better and in the other arches
> pte-based is better? What's the root reason?

Minchan might know more about this (or Russell King) but I'll give it
a try.

MMU designs can vary pretty significantly from arch to arch.  An
operation that is cheap on one MMU design can be expensive on another,
especially once SMP gets involved, possibly resulting in
inter-processor interrupts.

RAM speed is also a factor since the copy-method will use more memory
bandwidth.  Embedded systems typically won't have really fast memory.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
