Date: Tue, 19 Aug 2003 11:32:49 -0700
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: 2.6.0-test3-mm3
Message-ID: <20030819183249.GD19465@matchmail.com>
References: <20030819013834.1fa487dc.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030819013834.1fa487dc.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2003 at 01:38:34AM -0700, Andrew Morton wrote:
> +disable-athlon-prefetch.patch
> 
>  Disable prefetch() on all AMD CPUs.  It seems to need significant work to
>  get right and we're currently getting rare oopses with K7's.

Is this going to stay in -mm, or will it eventually propogate to stock?

If it does, can this be added to the to-do list of things to fix before 2.6.0?

I'd hate to see this feature lost...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
