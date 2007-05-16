Message-ID: <464AC00E.10704@yahoo.com.au>
Date: Wed, 16 May 2007 18:25:50 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>  <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>  <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>  <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>  <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org> <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Tue, 15 May 2007, Nicolas Mailhot wrote:
> 
>> Le lundi 14 mai 2007 a 19:24 +0100, Mel Gorman a ecrit :
>>
>>> On (14/05/07 11:13), Christoph Lameter didst pronounce:
>>>
>>>> I think the slub fragment may have to be this way? This calls
>>>> raise_kswapd_order on each kmem_cache_create with the order of the 
>>>> cache
>>>> that was created thus insuring that the min_order is correctly.
>>>>
>>>> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>>>>
>>>
>>> Good plan. Revised patch as follows;
>>
>>
>> Kernel with this patch and the other one survives testing. I'll stop
>> heavy testing now and consider the issue closed.
>>
> 
> That is good news, thanks for the report.
> 
>> Thanks for looking at my bug report.
>>
> 
> Thank you very much for your testing. I know it was a lot to ask to tie 
> a machine up for a few days.

Hmm, so we require higher order pages be kept free even if nothing is
using them? That's not very nice :(

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
