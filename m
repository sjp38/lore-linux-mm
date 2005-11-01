Date: Mon, 31 Oct 2005 19:05:09 -0500
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC][PATCH] madvise(MADV_TRUNCATE)
Message-ID: <20051101000509.GA11847@ccure.user-mode-linux.org>
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org> <43624F82.6080003@us.ibm.com> <20051028184235.GC8514@ccure.user-mode-linux.org> <1130544201.23729.167.camel@localhost.localdomain> <20051029025119.GA14998@ccure.user-mode-linux.org> <1130788176.24503.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1130788176.24503.19.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 31, 2005 at 11:49:36AM -0800, Badari Pulavarty wrote:
> Here is the latest patch. Still not cleaned up - but I thought I would
> get more feedback & testing while I finish cleanups (since they are all
> cosmetic).

This one looks a lot better.  I've been playing with it some, and no
unexpected behavior.

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
