Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E7B6C6B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 10:03:41 -0400 (EDT)
Message-ID: <4A76F27E.5070407@redhat.com>
Date: Mon, 03 Aug 2009 17:21:50 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/12] ksm: rename kernel_pages_allocated
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils> <Pine.LNX.4.64.0908031308590.16754@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908031308590.16754@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> We're not implementing swapping of KSM pages in its first release;
> but when that follows, "kernel_pages_allocated" will be a very poor
> name for the sysfs file showing number of nodes in the stable tree:
> rename that to "pages_shared" throughout.
>
> But we already have a "pages_shared", counting those page slots
> sharing the shared pages: first rename that to... "pages_sharing".
>
> What will become of "max_kernel_pages" when the pages shared can
> be swapped?  I guess it will just be removed, so keep that name.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>
>
>   
ACK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
