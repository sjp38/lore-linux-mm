Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E735D6B004D
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 02:29:02 -0500 (EST)
Received: by bwz28 with SMTP id 28so4838383bwz.14
        for <linux-mm@kvack.org>; Sun, 22 Feb 2009 23:29:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Date: Mon, 23 Feb 2009 09:29:00 +0200
Message-ID: <84144f020902222329u5754f8b1k790809191ac48f4a@mail.gmail.com>
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 1:17 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> The complexity of the page allocator has been increasing for some time
> and it has now reached the point where the SLUB allocator is doing strange
> tricks to avoid the page allocator. This is obviously bad as it may encourage
> other subsystems to try avoiding the page allocator as well.

I'm not an expert on the page allocator but the series looks sane to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

Yanmin, it would be interesting to know if we still need 8K kmalloc
caches with these patches applied. :-)

                               Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
