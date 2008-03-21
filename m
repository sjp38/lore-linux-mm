Date: Fri, 21 Mar 2008 10:31:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
In-Reply-To: <20080321.003100.155729406.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0803211031290.18671@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061727.491610308@sgi.com>
 <47E35D73.6060703@cosmosbay.com> <20080321.003100.155729406.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: dada1@cosmosbay.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Mar 2008, David Miller wrote:

> I agree with Eric, converting any of the networking hash
> allocations to this new facility is not the right thing
> to do.

Ok. Going to drop it.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
