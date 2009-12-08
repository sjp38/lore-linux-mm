Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8FF5C60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 18:10:29 -0500 (EST)
Subject: Re: [PATCH] [19/31] mm: export stable page flags
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20091208211635.7965AB151F@basil.firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
	 <20091208211635.7965AB151F@basil.firstfloor.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Dec 2009 16:27:31 -0600
Message-ID: <1260311251.31323.129.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: fengguang.wu@intel.com, npiggin@suse.de, cl@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-12-08 at 22:16 +0100, Andi Kleen wrote:
> From: Wu Fengguang <fengguang.wu@intel.com>
> 
> Rename get_uflags() to stable_page_flags() and make it a global function
> for use in the hwpoison page flags filter, which need to compare user
> page flags with the value provided by user space.
> 
> Also move KPF_* to kernel-page-flags.h for use by user space tools.
> 
> CC: Matt Mackall <mpm@selenic.com>
> CC: Nick Piggin <npiggin@suse.de>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: Andi Kleen <andi@firstfloor.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Acked-by: Matt Mackall <mpm@selenic.com>
-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
