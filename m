Date: Mon, 16 Feb 2004 18:42:57 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] 2.6.3-rc3-mm1: align scan_page per node
Message-ID: <20040216184257.A19515@infradead.org>
References: <4030BB86.8060206@cyberone.com.au><7090000.1076946440@[10.10.2.4]> <20040216095746.5ad2656b.akpm@osdl.org> <30430000.1076956618@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <30430000.1076956618@flay>; from mbligh@aracnet.com on Mon, Feb 16, 2004 at 10:36:58AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, piggin@cyberone.com.au, Nikita@Namesys.COM, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

struct_page.h is a horrible hear name.  Why not just page.h?

And yes, this would fix up a bunch of thing, in 2.7 we could also
merge page-flags.h into it..
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
