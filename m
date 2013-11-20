Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 29F6D6B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 19:21:14 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so1186515pdj.26
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 16:21:13 -0800 (PST)
Received: from psmtp.com ([74.125.245.138])
        by mx.google.com with SMTP id gn4si12772347pbc.201.2013.11.19.16.21.11
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 16:21:12 -0800 (PST)
Date: Wed, 20 Nov 2013 01:20:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm: tail page refcounting optimization for slab and
 hugetlbfs
Message-ID: <20131120002053.GE10493@redhat.com>
References: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
 <1384537668-10283-4-git-send-email-aarcange@redhat.com>
 <20131119151416.9f5b298960db09a21d37418b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131119151416.9f5b298960db09a21d37418b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hi Andrew!

On Tue, Nov 19, 2013 at 03:14:16PM -0800, Andrew Morton wrote:
> This looks like it was attacked by Lindent.  How's this look?

Indeed, I didn't try to optimize as 3/3 was mostly a test patch so
far.

> +	struct page *page_head;
> +
> +	if (likely(PageTail(page))) {

!PageTail here.

The current version would look like below, which is less obviously
horrible than before :). We may also consider to keep your indent
cleanup incremental as it's much easier to review the actual change of
code logic the below way.
