From: Andi Kleen <ak@suse.de>
Subject: Re: Page allocator: Single Zone optimizations
Date: Sat, 28 Oct 2006 09:12:01 -0700
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com> <20061027214324.4f80e992.akpm@osdl.org>
In-Reply-To: <20061027214324.4f80e992.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200610280912.01547.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It's all pretty simple.  But it'd be hacky to implement it in terms of
> "highmem".  It would be better if we could just tell the core MM "here's a
> 4G zone" and "here's a 60G zone".  The 60G zone is only used for
> GFP_HIGHUSER allocations and is hence unpluggable.
>
> I don't think there's any other (practical) way of implementing hot-unplug.

If it's implemented this way it would be important that the boundaries
between nodes are not fixed, but tunable. Otherwise kernel memory
intensive loads might be suddenly impossible.

>
> But hot-unplug is just an example.  My main point here is that it is
> desirable that we get away from the up-to-four magical hard-wired zones in
> core MM.

I mostly agree. At least GFP_DMA needs to go and replaced
with some API that gives memory masks and lets an underlying
allocator figure it out. GFP_DMA32 might still have a better case
though because those are pretty common, but ultimatively
a mask based interface is here much better too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
