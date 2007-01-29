Date: Mon, 29 Jan 2007 17:28:39 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/8] Create the ZONE_MOVABLE zone
In-Reply-To: <Pine.LNX.4.64.0701260822510.6141@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0701291727500.15953@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070125234538.28809.24662.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260822510.6141@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Christoph Lameter wrote:

> On Thu, 25 Jan 2007, Mel Gorman wrote:
>
>> @@ -166,6 +168,8 @@ enum zone_type {
>>  #define ZONES_SHIFT 1
>>  #elif __ZONE_COUNT <= 4
>>  #define ZONES_SHIFT 2
>> +#elif __ZONE_COUNT <= 8
>> +#define ZONES_SHIFT 3
>>  #else
>
> You do not need a shift of 3. Even with ZONE_MOVABLE the maximum
> number of zones is still 4.
>

Yep, this is correct. If it's ever wrong, there is an additional check for 
__ZONE_COUNT that will print out the appropriate warning.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
