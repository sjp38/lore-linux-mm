Date: Tue, 8 Jul 2003 18:29:21 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [announce, patch] 4G/4G split on x86, 64 GB RAM (and more) support
Message-ID: <20030709012921.GJ15452@holomorphy.com>
References: <Pine.LNX.4.44.0307082332450.17252-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0307082332450.17252-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 09, 2003 at 12:45:52AM +0200, Ingo Molnar wrote:
> The patch is orthogonal to wli's pgcl patch - both patches try to achieve
> the same, with different methods. I can very well imagine workloads where
> we want to have the combination of the two patches.

Well, your patch does have the advantage of not being a "break all
drivers" affair.

Also, even though pgcl scales "perfectly" wrt. highmem (nm the code
being a train wreck), the raw capacity increase is needed. There are
enough other reasons to go through with ABI-preserving page clustering
that they're not really in competition with each other.

Looks good to me. I'll spin it up tonight.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
