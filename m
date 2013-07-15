Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id A5B686B0031
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 11:00:41 -0400 (EDT)
Date: Mon, 15 Jul 2013 10:00:40 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC 0/4] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130715150040.GA3421@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373594635-131067-1-git-send-email-holt@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>
Cc: Robin Holt <holt@sgi.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

On Thu, Jul 11, 2013 at 09:03:51PM -0500, Robin Holt wrote:
> We have been working on this since we returned from shutdown and have
> something to discuss now.  We restricted ourselves to 2MiB initialization
> to keep the patch set a little smaller and more clear.
> 
> First, I think I want to propose getting rid of the page flag.  If I knew
> of a concrete way to determine that the page has not been initialized,
> this patch series would look different.  If there is no definitive
> way to determine that the struct page has been initialized aside from
> checking the entire page struct is zero, then I think I would suggest
> we change the page flag to indicate the page has been initialized.

Ingo or HPA,

Did I implement this wrong or is there a way to get rid of the page flag
which is not going to impact normal operation?  I don't want to put too
much more effort into this until I know we are stuck going this direction.
Currently, the expand() function has a relatively expensive checked
against the 2MiB aligned pfn's struct page.  I do not know of a way to
eliminate that check against the other page as the first reference we
see for a page is in the middle of that 2MiB aligned range.

To identify this as an area of concern, we had booted with a simulator,
setting watch points on the struct page array region once the
Uninitialized flag was set and maintaining that until it was cleared.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
