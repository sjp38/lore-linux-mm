Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EACBA6B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 10:16:13 -0400 (EDT)
Message-ID: <4A76F57A.7090805@redhat.com>
Date: Mon, 03 Aug 2009 17:34:34 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/12] ksm: move pages_sharing updates
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils> <Pine.LNX.4.64.0908031310060.16754@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908031310060.16754@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> The pages_shared count is incremented and decremented when adding a node
> to and removing a node from the stable tree: easy to understand.  But the
> pages_sharing count was hard to follow, being adjusted in various places:
> increment and decrement it when adding to and removing from the stable tree.
>
> And the pages_sharing variable used to include the pages_shared, then those
> were subtracted when shown in the pages_sharing sysfs file: now keep it as
> an exclusive count of leaves hanging off the stable tree nodes, throughout.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>
>   
ACK, (Code is simpler that way)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
