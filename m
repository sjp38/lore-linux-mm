Return-Path: <linux-kernel-owner+w=401wt.eu-S1759036AbYLLJnT@vger.kernel.org>
Date: Fri, 12 Dec 2008 10:43:02 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] SLQB slab allocator
Message-ID: <20081212094302.GC14225@wotan.suse.de>
References: <20081212002518.GH8294@wotan.suse.de> <4941F8D2.4060807@cosmosbay.com> <20081212055051.GE15804@wotan.suse.de> <49420DAB.7090604@cosmosbay.com> <20081212072355.GG15804@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081212072355.GG15804@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 12, 2008 at 08:23:55AM +0100, Nick Piggin wrote:
> Anyway, I'll see if I can work out why SLQB is slower. Do you have
> socketallocbench online?

Hmph, it seems to be in the noise (I'm testing with an AMD system
though). Some boots SLAB is faster, other boots, SLQB is. Could be
a matter of luck in cacheline placement maybe?

I think this benchmark (after the slab rcu patch) will be pretty
trivial for any slab allocator because it will basically be each
CPU allocating then freeing an object.
