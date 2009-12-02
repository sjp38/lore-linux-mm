Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D7356600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:09:08 -0500 (EST)
Date: Wed, 2 Dec 2009 14:09:04 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 02/24] migrate: page could be locked by hwpoison, dont BUG()
Message-ID: <20091202130904.GD18989@one.firstfloor.org>
References: <20091202031231.735876003@intel.com> <20091202043043.840044332@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202043043.840044332@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 11:12:33AM +0800, Wu Fengguang wrote:
> The new page could be taken by hwpoison, in which case
> return EAGAIN to allocate a new page and retry.

Previously there were some complaints about this patch, but I guess
it doesn't hurt, so I'll add it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
