Date: Sat, 28 Aug 2004 15:13:49 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on
 swap partition
Message-Id: <20040828151349.00f742f4.akpm@osdl.org>
In-Reply-To: <20040828215411.GY5492@holomorphy.com>
References: <20040824124356.GW2355@suse.de>
	<412CDE7E.9060307@seagha.com>
	<20040826144155.GH2912@suse.de>
	<412E13DB.6040102@seagha.com>
	<412E31EE.3090102@pandora.be>
	<41308C62.7030904@seagha.com>
	<20040828125028.2fa2a12b.akpm@osdl.org>
	<4130F55A.90705@pandora.be>
	<20040828144303.0ae2bebe.akpm@osdl.org>
	<20040828215411.GY5492@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: karl.vogel@pandora.be, axboe@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
> Karl Vogel <karl.vogel@pandora.be> wrote:
> >> With overcommit_memory set to 1, the program can be run again after the 
> >> OOM kill.. but the OOM killing remains.
> >> With overcommit_memory set to 0 a second run fails. I 'think' it's 
> >> because somehow SwapCache is 500Kb after the OOM, so in effect my system 
> >> doesn't have 1Gb to spare anymore. Doing swapoff/swapon frees this and 
> >> then I can do the calloc(1Gb) again.
> >> Another way to free the SwapCached is to generate lots of I/O doing 'dd 
> >> if=/dev/hda of=/dev/null' ... after a while SwapCached is < 1Mb again.
> 
> On Sat, Aug 28, 2004 at 02:43:03PM -0700, Andrew Morton wrote:
> > urgh.  It sounds like the overcommit logic forgot to account swapcache as
> > reclaimable.  It's been a ton of trouble, that code.
> 
> For overcommit purposes, swapcache still counts as committed AS; it
> requires swap as backing store to evict. So AFAICT there isn't an issue
> there.

But that backing store is allocated?

> I was under the impression this had something to do with IO
> schedulers.

Separate issue.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
