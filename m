Message-ID: <451A6034.20305@shadowen.org>
Date: Wed, 27 Sep 2006 12:27:48 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Get rid of zone_table V2
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>	<20060924030643.e57f700c.akpm@osdl.org> <20060927021934.9461b867.akpm@osdl.org>
In-Reply-To: <20060927021934.9461b867.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sun, 24 Sep 2006 03:06:43 -0700
> Andrew Morton <akpm@osdl.org> wrote:
> 
>> On Mon, 18 Sep 2006 12:21:35 -0700 (PDT)
>> Christoph Lameter <clameter@sgi.com> wrote:
>>
>>>  static inline int page_zone_id(struct page *page)
>>>  {
>>> -	return (page->flags >> ZONETABLE_PGSHIFT) & ZONETABLE_MASK;
>>> -}
>>> -static inline struct zone *page_zone(struct page *page)
>>> -{
>>> -	return zone_table[page_zone_id(page)];
>>> +	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
>>>  }
>> arm allmodconfig:
>>
>> include/linux/mm.h: In function `page_zone_id':
>> include/linux/mm.h:450: warning: right shift count >= width of type

On a separate note.  I was able to get this puppy compiling enough to
see this warning and fix it, but nowhere close to compiling a kernel.

First, are you compiling here to a real kernel.  If so, is this on a
cross-compiler or a real system.  If its a cross-compiler which version.
  Do you have recipe for success?

I'd like to be incoporating more cross-compilation testing into our
nightlies, but this one isn't playing ball.

:/

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
