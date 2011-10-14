Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 38E596B01A5
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 05:54:24 -0400 (EDT)
Message-ID: <4E9806CE.8020506@kernel.dk>
Date: Fri, 14 Oct 2011 11:54:22 +0200
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
References: <1318500176-10728-1-git-send-email-ian.campbell@citrix.com> <4E97D9E4.4090202@kernel.dk> <alpine.DEB.2.00.1110140215380.21487@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110140215380.21487@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ian Campbell <ian.campbell@citrix.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org

On 2011-10-14 11:17, David Rientjes wrote:
> On Fri, 14 Oct 2011, Jens Axboe wrote:
> 
>> Looks good to me, I can switch struct bio_vec over to this once it's in.
>>
> 
> Looks like it could also be embedded within struct pipe_buffer.

Yep, that too.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
