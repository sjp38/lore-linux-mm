Date: Mon, 13 Sep 2004 16:45:10 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Do not mark being-truncated-pages as cache hot
Message-Id: <20040913164510.249eb7b1.akpm@osdl.org>
In-Reply-To: <20040913215753.GA23119@logos.cnet>
References: <20040913215753.GA23119@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, mbligh@aracnet.com, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> The truncate VM functions use pagevec's for operation batching, but they mark
>  the pagevec used to hold being-truncated-pages as "cache hot". 
> 
>  There is nothing which indicates such pages are likely to be "cache hot" - the
>  following patch marks being-truncated-pages as cold instead. 

Disagree.

	blah > /tmp/foo
	rm /tmp/foo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
