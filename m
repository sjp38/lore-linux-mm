Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D5416B0078
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 00:24:16 -0500 (EST)
Date: Wed, 24 Feb 2010 16:24:09 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC] nfs: use 2*rsize readahead size
Message-ID: <20100224052409.GI16175@discord.disaster>
References: <20100224024100.GA17048@localhost> <20100224032934.GF16175@discord.disaster> <20100224042414.GG16175@discord.disaster> <20100224044356.GA2007@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100224044356.GA2007@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 12:43:56PM +0800, Wu Fengguang wrote:
> On Wed, Feb 24, 2010 at 12:24:14PM +0800, Dave Chinner wrote:
> > On Wed, Feb 24, 2010 at 02:29:34PM +1100, Dave Chinner wrote:
> > > That's doing a cached read out of the server cache, right? You
> > > might find the results are different if the server has to read the
> > > file from disk. I would expect reads from the server cache not
> > > to require much readahead as there is no IO latency on the server
> > > side for the readahead to hide....
> > 
> > FWIW, if you mount the client with "-o rsize=32k" or the server only
> > supports rsize <= 32k then this will probably hurt throughput a lot
> > because then readahead will be capped at 64k instead of 480k....
> 
> I should have mentioned that in changelog.. Hope the updated one
> helps.

Sorry, my fault for not reading the code correctly.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
