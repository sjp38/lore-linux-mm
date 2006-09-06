Date: Wed, 6 Sep 2006 15:46:43 +0200
From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 10/21] block: elevator selection and pinning
Message-ID: <20060906134642.GC14565@kernel.dk>
References: <20060906131630.793619000@chello.nl>> <20060906133954.673752000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060906133954.673752000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 06 2006, Peter Zijlstra wrote:
> Provide an block queue init function that allows to set an elevator. And a 
> function to pin the current elevator.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Daniel Phillips <phillips@google.com>
> CC: Jens Axboe <axboe@suse.de>
> CC: Pavel Machek <pavel@ucw.cz>

Generally I don't think this is the right approach, as what you really
want to do is let the driver say "I want intelligent scheduling" or not.
The type of scheduler is policy that is left with the user, not the
driver.

And this patch seems to do two things, and you don't explain what the
pinning is useful for at all.

So that's 2 for 2 currently, NAK from me.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
