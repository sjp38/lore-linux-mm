Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C9C7E6B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 18:33:11 -0500 (EST)
Date: Mon, 21 Nov 2011 15:33:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/8] readahead: basic support for backwards prefetching
Message-Id: <20111121153309.d2a410fb.akpm@linux-foundation.org>
In-Reply-To: <20111121093846.887841399@intel.com>
References: <20111121091819.394895091@intel.com>
	<20111121093846.887841399@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Li Shaohua <shaohua.li@intel.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, 21 Nov 2011 17:18:26 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Add the backwards prefetching feature. It's pretty simple if we don't
> support async prefetching and interleaved reads.

Well OK, but I wonder how many applications out there read files in
reverse order.  Is it common enough to bother special-casing in the
kernel like this?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
