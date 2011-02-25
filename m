Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1B8128D003A
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 19:52:06 -0500 (EST)
Date: Fri, 25 Feb 2011 01:51:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110225005155.GH23252@random.random>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
 <1298425922-23630-9-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298425922-23630-9-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Tue, Feb 22, 2011 at 05:52:02PM -0800, Andi Kleen wrote:
> +	"thp_direct_alloc",
> +	"thp_daemon_alloc",
> +	"thp_direct_fallback",
> +	"thp_daemon_alloc_failed",

I've been wondering if we should do s/daemon/khugepaged/ or
s/daemon/collapse/.

And s/direct/fault/.

Comments welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
