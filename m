Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8A96B008C
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 05:33:12 -0500 (EST)
Date: Mon, 20 Dec 2010 05:33:07 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 0/5] Change page reference hanlding semantic of page cache
Message-ID: <20101220103307.GA22986@infradead.org>
References: <cover.1292604745.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

You'll need to merge all patches into one, otherwise you create really
nasty memory leaks when bisecting between them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
