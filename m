Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A6D956B00CD
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 08:02:47 -0500 (EST)
Received: by iaek3 with SMTP id k3so2034135iae.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 05:02:46 -0800 (PST)
Message-ID: <4ECCEEA8.3030002@gmail.com>
Date: Wed, 23 Nov 2011 21:01:28 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] cleanup: convert the int cnt to unsigned long in
 mm/memblock.c
References: <4EB9DF0B.7050004@gmail.com>	<4EBA0D3D.1090808@gmail.com> <20111122155901.e7b23dce.akpm@linux-foundation.org>
In-Reply-To: <20111122155901.e7b23dce.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2011a1'11ae??23ae?JPY 07:59, Andrew Morton wrote:
> On Wed, 09 Nov 2011 13:18:53 +0800
> Wang Sheng-Hui <shhuiw@gmail.com> wrote:
> 
>> @@ -111,7 +112,7 @@ static phys_addr_t __init_memblock memblock_find_region(phys_addr_t start, phys_
>>  static phys_addr_t __init_memblock memblock_find_base(phys_addr_t size,
>>  			phys_addr_t align, phys_addr_t start, phys_addr_t end)
>>  {
>> -	long i;
>> +	unsigned long i;
>>  
>>  	BUG_ON(0 == size);
> 
> This change to memblock_find_base() can cause this loop:
> 
> 	for (i = memblock.memory.cnt - 1; i >= 0; i--) {
> 
> to become infinite under some circumstances.
> 
> I stopped reading at that point.  Changes like this require much care.
> 

Got it.

Thanks for your instructions. 
I'll review the code and may resubmit the right patches later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
