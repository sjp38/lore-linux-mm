Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F33796B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 11:41:44 -0400 (EDT)
Message-ID: <4A7709A0.4060402@redhat.com>
Date: Mon, 03 Aug 2009 19:00:32 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/12] ksm: break cow once unshared
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils> <Pine.LNX.4.64.0908031311590.16754@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908031311590.16754@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> We kept agreeing not to bother about the unswappable shared KSM pages
> which later become unshared by others: observation suggests they're not
> a significant proportion.  But they are disadvantageous, and it is easier
> to break COW to replace them by swappable pages, than offer statistics
> to show that they don't matter; then we can stop worrying about them.
>
> Doing this in ksm_do_scan, they don't go through cmp_and_merge_page on
> this pass: give them a good chance of getting into the unstable tree
> on the next pass, or back into the stable, by computing checksum now.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
ACK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
