Date: Sat, 28 Aug 2004 15:28:16 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040828222816.GZ5492@holomorphy.com>
References: <412CDE7E.9060307@seagha.com> <20040826144155.GH2912@suse.de> <412E13DB.6040102@seagha.com> <412E31EE.3090102@pandora.be> <41308C62.7030904@seagha.com> <20040828125028.2fa2a12b.akpm@osdl.org> <4130F55A.90705@pandora.be> <20040828144303.0ae2bebe.akpm@osdl.org> <20040828215411.GY5492@holomorphy.com> <20040828151349.00f742f4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040828151349.00f742f4.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: karl.vogel@pandora.be, axboe@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>> For overcommit purposes, swapcache still counts as committed AS; it
>> requires swap as backing store to evict. So AFAICT there isn't an issue
>> there.

On Sat, Aug 28, 2004 at 03:13:49PM -0700, Andrew Morton wrote:
> But that backing store is allocated?

Committed AS is so regardless of whether backing store has been
allocated. If it has been allocated, the reservation is cashed and held.
If it hasn't been allocated, it is reserved and held, but not cashed.
In both those cases, the reservation is still held. For anonymous memory,
the reservations are not released until it's freed, as that's the only
way for an anonymous page to make a transition to not being swap-backed.


William Lee Irwin III <wli@holomorphy.com> wrote:
>> I was under the impression this had something to do with IO
>> schedulers.

On Sat, Aug 28, 2004 at 03:13:49PM -0700, Andrew Morton wrote:
> Separate issue.

It certainly appears to be the deciding factor from the thread.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
