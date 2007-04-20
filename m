Date: Fri, 20 Apr 2007 14:03:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE 2/2
Message-Id: <20070420140316.e0155e7d.akpm@linux-foundation.org>
In-Reply-To: <4627DBF0.1080303@redhat.com>
References: <46247427.6000902@redhat.com>
	<4627DBF0.1080303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Jakub Jelinek <jakub@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2007 17:15:28 -0400
Rik van Riel <riel@redhat.com> wrote:

> Restore MADV_DONTNEED to its original Linux behaviour.  This is still
> not the same behaviour as POSIX, but applications may be depending on
> the Linux behaviour already. Besides, glibc catches POSIX_MADV_DONTNEED
> and makes sure nothing is done...

OK, we need to flesh this out a lot please.  People often get confused
about what our MADV_DONTNEED behaviour is.  I regularly forget, then look
at the code, then get it wrong.  That's for mainline, let alone older
kernels whose behaviour is gawd-knows-what.

So...  For the changelog (and the manpage) could we please have a full
description of the 2.6.21 behaviour and the 2.6.21-post-rik behaviour (and
the 2.4 behaviour, if it differs at all)?  Also some code comments to
demystify all of this once and for all?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
