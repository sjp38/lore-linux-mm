Message-ID: <418AD391.40909@yahoo.com.au>
Date: Fri, 05 Nov 2004 12:12:49 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] higher order watermarks
References: <417F5584.2070400@yahoo.com.au> <417F55B9.7090306@yahoo.com.au> <417F5604.3000908@yahoo.com.au> <20041104085745.GA7186@logos.cnet> <418A1EA6.70500@yahoo.com.au> <20041104100226.GB7902@logos.cnet>
In-Reply-To: <20041104100226.GB7902@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> On Thu, Nov 04, 2004 at 11:20:54PM +1100, Nick Piggin wrote:

>>Probably the comment there is woefully inadequate? - I sometimes forget that
>>people can't read my mind :\
> 
> 
> Nick, care to add a comment on top of zone_watermark_ok explaining 
> the reasoning behind the calculation and its expected effects? 
> 
> That would be really nice.

Yep, I'll come up with something for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
