Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A46CF6B0074
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 16:26:10 -0400 (EDT)
Date: Thu, 1 Nov 2012 20:26:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Support volatile range for anon vma
In-Reply-To: <20121026005851.GD15767@bbox>
Message-ID: <0000013abda6fc7d-6cfbef1e-bc7d-4f4f-bb38-221729e8c9f9-000000@email.amazonses.com>
References: <1351133820-14096-1-git-send-email-minchan@kernel.org> <0000013a9881a86c-c0fb5823-b6e7-4bea-8707-f6b8eddae14d-000000@email.amazonses.com> <20121026005851.GD15767@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 26 Oct 2012, Minchan Kim wrote:

> I guess it would improve system performance very well.
> But as I wrote down in description, downside of the patch is that we have to
> age anon lru although we don't have swap. But gain via the patch is bigger than
> loss via aging of anon lru when memory pressure happens. I don't see other downside
> other than it. What do you think about it?
> (I didn't implement anon lru aging in case of no-swap but it's trivial
> once we decide)


I am a bit confused like some of the others as to why this patch is
necessary since we already have DONT_NEED.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
