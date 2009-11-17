Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B461B6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 05:27:04 -0500 (EST)
Date: Tue, 17 Nov 2009 05:27:01 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/7] Kill PF_MEMALLOC abuse
Message-ID: <20091117102701.GA16472@infradead.org>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com> <20091117101526.GA4797@infradead.org> <20091117192232.3DF9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091117192232.3DF9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 17, 2009 at 07:24:42PM +0900, KOSAKI Motohiro wrote:
> if xfsbufd doesn't only write out dirty data but also drop page,
> I agree you. 

It then drops the reference to the buffer which drops references to the
pages, which often are the last references, yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
