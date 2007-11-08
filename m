Date: Wed, 07 Nov 2007 17:45:17 -0800 (PST)
Message-Id: <20071107.174517.243840860.davem@davemloft.net>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded
 insertions
From: David Miller <davem@davemloft.net>
In-Reply-To: <20071107174114.ff922fec.akpm@linux-foundation.org>
References: <20071107170923.6cf3c389.akpm@linux-foundation.org>
	<20071107.173419.22426986.davem@davemloft.net>
	<20071107174114.ff922fec.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 7 Nov 2007 17:41:14 -0800
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > On Wed, 07 Nov 2007 17:34:19 -0800 (PST) David Miller <davem@davemloft.net> wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Wed, 7 Nov 2007 17:09:23 -0800
> > 
> > > Why not just stomp the warning with __GFP_NOWARN?
> > > 
> > > Did you consider turning off __GFP_HIGH?  (Dunno why)
> > > 
> > > This change will slow things down - has this been quantified?  Probably
> > > it's unmeasurable, but it's still there.
> > > 
> > > I'd have thought that a superior approach would be to just set
> > > __GFP_NOWARN?
> > 
> > I've rerun my test case which triggers this on Niagara 2
> > and I no longer get the messages.
> 
> With Nick's patch, I assume?

Yes, that's correct.

> Yeah, draining the GFP_ATOMIC reserves is bad.  Setting __GFP_NOWARN and
> clearing __GFP_HIGH should plug this, but which appropach is the best? 
> Unsure.

I like the locking aspects of Nick's patch personally.

This will allow us to do more interesting things in
the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
