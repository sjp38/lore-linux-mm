Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94291600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:15:53 -0500 (EST)
Date: Wed, 2 Dec 2009 14:15:50 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 13/24] HWPOISON: introduce struct hwpoison_control
Message-ID: <20091202131550.GH18989@one.firstfloor.org>
References: <20091202031231.735876003@intel.com> <20091202043045.258152715@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202043045.258152715@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 11:12:44AM +0800, Wu Fengguang wrote:
> This allows passing around more parameters and states.
> No behavior change.

As mentioned earlier I'll skip this patch for now.
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
