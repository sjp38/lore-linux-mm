Date: Mon, 16 Feb 2004 10:45:48 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 2.6.3-rc3-mm1: align scan_page per node
Message-Id: <20040216104548.753cd461.akpm@osdl.org>
In-Reply-To: <20040216184257.A19515@infradead.org>
References: <4030BB86.8060206@cyberone.com.au>
	<7090000.1076946440@[10.10.2.4]>
	<20040216095746.5ad2656b.akpm@osdl.org>
	<30430000.1076956618@flay>
	<20040216184257.A19515@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: mbligh@aracnet.com, piggin@cyberone.com.au, Nikita@Namesys.COM, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@infradead.org> wrote:
>
> struct_page.h is a horrible hear name.  Why not just page.h?

Because we already have include/asm/page.h, which serves an unrelated
function.

pageframe.h sounds OK.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
