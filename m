Date: Fri, 8 Sep 2006 10:20:16 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/8] Split the free lists into kernel and user parts
In-Reply-To: <1157702040.17799.40.camel@lappy>
Message-ID: <Pine.LNX.4.64.0609081019040.7094@skynet.skynet.ie>
References: <20060907190342.6166.49732.sendpatchset@skynet.skynet.ie>
 <20060907190422.6166.49758.sendpatchset@skynet.skynet.ie>
 <1157702040.17799.40.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Sep 2006, Peter Zijlstra wrote:

> Hi Mel,
>
> Looking good, some small nits follow.
>
> On Thu, 2006-09-07 at 20:04 +0100, Mel Gorman wrote:
>
>> +#define for_each_rclmtype_order(type, order) \
>> +	for (order = 0; order < MAX_ORDER; order++) \
>> +		for (type = 0; type < RCLM_TYPES; type++)
>
> It seems odd to me that you have the for loops in reverse order of the
> arguments.
>

I'll fix that.

>> +static inline int get_pageblock_type(struct page *page)
>> +{
>> +	return (PageEasyRclm(page) != 0);
>> +}
>
> I find the naming a little odd, I would have suspected something like:
> get_page_blocktype() or thereabout since you're getting a page
> attribute.
>

This is a throwback from an early version when I used a bitmap that used 
one bit per MAX_ORDER_NR_PAGES block of pages. Many pages in a block 
shared one bit - hence get_pageblock_type(). The name is now stupid. I'll 
fix it.

>> +static inline int gfpflags_to_rclmtype(unsigned long gfp_flags)
>> +{
>> +	return ((gfp_flags & __GFP_EASYRCLM) != 0);
>> +}
>
> gfp_t argument?
>

doh, yes, it should be gfp_t

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
