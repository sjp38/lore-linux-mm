Date: Thu, 6 Nov 2008 09:04:54 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 7/7] cpu alloc: page allocator conversion
In-Reply-To: <20081106115113.0D38.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0811060904030.3595@quilx.com>
References: <20081105231634.133252042@quilx.com> <20081105231650.526116017@quilx.com>
 <20081106115113.0D38.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008, KOSAKI Motohiro wrote:

> > -		free_zone_pagesets(cpu);
> > +		process_zones(cpu);
> >  		break;
>
> Why do you drop cpu unplug code?

Because it does not do anything. Percpu areas are traditionally allocated
for each possible cpu not for each online cpu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
