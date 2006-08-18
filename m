Date: Thu, 17 Aug 2006 19:25:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/1] network memory allocator.
In-Reply-To: <20060816142557.acccdfcf.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0608171920220.28680@schroedinger.engr.sgi.com>
References: <20060814110359.GA27704@2ka.mipt.ru> <200608152221.22883.arnd@arndb.de>
 <20060816053545.GB22921@2ka.mipt.ru> <20060816084808.GA7366@infradead.org>
 <20060816142557.acccdfcf.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Aug 2006, Andi Kleen wrote:

> That's not true on all NUMA systems (that they have a slow interconnect)
> I think on x86-64 I would prefer if it was distributed evenly or maybe even 
> on the CPU who is finally going to process it.
> 
> -Andi "not all NUMA is an Altix"

The Altix NUMA interconnect has the same speed as far as I can recall as 
Hypertransport. It is the distance (real physical cable length) that 
creates latencies for huge systems. Sadly the Hypertransport is designed 
to stay on the motherboard. Hypertransport can only be said to be fast 
because its only used for tinzy winzy systems of a few processors. Are 
you saying that the design limitations of Hypertransport are an 
advantage?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
