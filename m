Date: Thu, 13 Apr 2000 21:34:36 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: page->offset
In-Reply-To: <20000413090746.R13396@mea.tmt.tele.fi>
Message-ID: <Pine.LNX.4.21.0004132133410.9980-100000@maclaurin.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matti Aarnio <matti.aarnio@sonera.fi>
Cc: pnilesh@in.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Apr 2000, Matti Aarnio wrote:

>	Scaled with PAGE SIZE.

PAGE_CACHE_SIZE

>	Reason for going to this has been (among others) to get
>	coherency into the page cache so that there won't be
>	differently aligned copies of same byte range in the memory.

Very right. Other strong reason was to avoid long long with LFS.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
