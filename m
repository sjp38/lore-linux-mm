Date: Mon, 13 Sep 2004 17:24:32 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] Do not mark being-truncated-pages as cache hot
Message-ID: <72070000.1095121472@flay>
In-Reply-To: <20040913171037.793d4f68.akpm@osdl.org>
References: <20040913215753.GA23119@logos.cnet><66880000.1095120205@flay> <20040913171037.793d4f68.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

> "Martin J. Bligh" <mbligh@aracnet.com> wrote:
>> 
>> > - Making the allocation policy FIFO should drastically increase the chances "hot" pages
>>  > are handed to the allocator. AFAIK the policy now is LIFO.
>> 
>>  It should definitely have been FIFO to start with
> 
> I always intended that it be LIFO.  Take the hottest page, for heavens
> sake.  As the oldest page is the one which is most likely to have fallen
> out of cache then why a-priori choose it?

Bah. I just had my acronyms backwards ... I meant LIFO, sorry ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
