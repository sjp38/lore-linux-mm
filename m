Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 82C266B005A
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 03:34:46 -0500 (EST)
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <84144f020902222329u5754f8b1k790809191ac48f4a@mail.gmail.com>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	 <84144f020902222329u5754f8b1k790809191ac48f4a@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 23 Feb 2009 16:34:25 +0800
Message-Id: <1235378065.2604.434.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-23 at 09:29 +0200, Pekka Enberg wrote:
> On Mon, Feb 23, 2009 at 1:17 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > The complexity of the page allocator has been increasing for some time
> > and it has now reached the point where the SLUB allocator is doing strange
> > tricks to avoid the page allocator. This is obviously bad as it may encourage
> > other subsystems to try avoiding the page allocator as well.
> 
> I'm not an expert on the page allocator but the series looks sane to me.
> 
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> Yanmin, it would be interesting to know if we still need 8K kmalloc
> caches with these patches applied. :-)
We are running testing against the series of patches on top of 2.6.29-rc5, and
will keep you posted on the results.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
