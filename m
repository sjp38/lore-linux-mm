Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7DCA46B01A4
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 05:17:57 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p9E9HprB001932
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 02:17:54 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by wpaz17.hot.corp.google.com with ESMTP id p9E9Hnbn017823
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 02:17:50 -0700
Received: by pzk6 with SMTP id 6so1135426pzk.11
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 02:17:49 -0700 (PDT)
Date: Fri, 14 Oct 2011 02:17:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
In-Reply-To: <4E97D9E4.4090202@kernel.dk>
Message-ID: <alpine.DEB.2.00.1110140215380.21487@chino.kir.corp.google.com>
References: <1318500176-10728-1-git-send-email-ian.campbell@citrix.com> <4E97D9E4.4090202@kernel.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Ian Campbell <ian.campbell@citrix.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org

On Fri, 14 Oct 2011, Jens Axboe wrote:

> Looks good to me, I can switch struct bio_vec over to this once it's in.
> 

Looks like it could also be embedded within struct pipe_buffer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
