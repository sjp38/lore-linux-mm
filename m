Date: Mon, 13 Sep 2004 17:10:37 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Do not mark being-truncated-pages as cache hot
Message-Id: <20040913171037.793d4f68.akpm@osdl.org>
In-Reply-To: <66880000.1095120205@flay>
References: <20040913215753.GA23119@logos.cnet>
	<66880000.1095120205@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> > - Making the allocation policy FIFO should drastically increase the chances "hot" pages
>  > are handed to the allocator. AFAIK the policy now is LIFO.
> 
>  It should definitely have been FIFO to start with

I always intended that it be LIFO.  Take the hottest page, for heavens
sake.  As the oldest page is the one which is most likely to have fallen
out of cache then why a-priori choose it?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
