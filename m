Date: Mon, 14 Aug 2006 09:20:16 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
Message-ID: <20060814052015.GB1335@2ka.mipt.ru>
References: <20060812141415.30842.78695.sendpatchset@lappy> <33471.81.207.0.53.1155401489.squirrel@81.207.0.53> <1155404014.13508.72.camel@lappy> <47227.81.207.0.53.1155406611.squirrel@81.207.0.53> <1155408846.13508.115.camel@lappy> <44DFC707.7000404@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <44DFC707.7000404@google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Indan Zupancic <indan@nul.nu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 13, 2006 at 05:42:47PM -0700, Daniel Phillips (phillips@google.com) wrote:
> High order allocations are just way too undependable without active
> defragmentation, which isn't even on the horizon at the moment.  We
> just need to treat any network hardware that can't scatter/gather into
> single pages as too broken to use for network block io.

A bit of network tree allocator free advertisement - per-CPU self 
defragmentation works reliably in that allocator, one could even find a
graphs of memory usage for NTA and SLAB-like allocator.

> As for sk_buff cow break, we need to look at which network paths do it
> (netfilter obviously, probably others) and decide whether we just want
> to declare that the feature breaks network block IO, or fix the feature
> so it plays well with reserve accounting.

I would suggest to consider skb cow (cloning) as a must.


> Regards,
> 
> Daniel

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
