Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 37C986B011C
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:50:04 -0400 (EDT)
Message-ID: <4DFF8848.2060802@redhat.com>
Date: Mon, 20 Jun 2011 13:50:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165844.GA9396@suse.de> <4DFF7E3B.1040404@redhat.com> <4DFF7F0A.8090604@redhat.com> <4DFF8106.8090702@redhat.com> <4DFF8327.1090203@redhat.com> <4DFF84BB.3050209@redhat.com>
In-Reply-To: <4DFF84BB.3050209@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On 06/20/2011 01:34 PM, Cong Wang wrote:

> Even if it is really 10K, why not save it since it doesn't
> much effort to make this. ;) Not only memory, but also time,
> this could also save a little time to initialize the kernel.
>
> For me, the more serious thing is the logic, there is
> no way to totally disable it as long as I have THP in .config
> currently. This is why I said the design is broken.

There are many things you cannot totally disable as long
as they are enabled in the .config.  Think about things
like swap, or tmpfs - neither of which you are going to
use in the crashdump kernel.

I believe we need to keep the kernel optimized for common
use and convenience.

Crashdump is very much a corner case.  Yes, using less
memory in crashdump is worthwhile, but lets face it -
the big memory user there is likely to be the struct page
array, with everything else down in the noise...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
