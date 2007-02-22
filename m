Date: Thu, 22 Feb 2007 07:26:37 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: The unqueued Slab allocator
In-Reply-To: <20070222.005824.34601725.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0702220726010.858@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
 <20070222.005824.34601725.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

n Thu, 22 Feb 2007, David Miller wrote:

> All of that logic needs to be protected by CONFIG_ZONE_DMA too.

Right. Will fix that in the next release.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
