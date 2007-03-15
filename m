Date: Thu, 15 Mar 2007 13:45:31 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] splice: dont steal
Message-ID: <20070315124531.GD8321@wotan.suse.de>
References: <20070314121440.GA926@wotan.suse.de> <20070315115237.GM15400@kernel.dk> <20070315122207.GA8321@wotan.suse.de> <20070315122723.GQ15400@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070315122723.GQ15400@kernel.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 01:27:23PM +0100, Jens Axboe wrote:
> On Thu, Mar 15 2007, Nick Piggin wrote:
> > 
> > We should be able to allow for it with the new a_ops API I'm working
> > on.
> 
> "Should be" and in progress stuff, is it guarenteed to get there?

Well considering that it is needed in order to solve 3 different deadlock
scenarios in the core write(2) path without taking a big performance hit,
I'd hope so ;)

It isn't guaranteed, but I have only had positive feedback so far. Would
take a while to actually get merged, though.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
