Date: Mon, 26 Feb 2007 16:36:42 -0800 (PST)
Message-Id: <20070226.163642.59469811.davem@davemloft.net>
Subject: Re: [PATCH] SLUB v2
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0702242234060.20557@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702242234060.20557@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@engr.sgi.com>
Date: Sat, 24 Feb 2007 22:36:26 -0800 (PST)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@engr.sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> V1->V2
> - Fix up various issues. Tested on i386 UP, X86_64 SMP, ia64 NUMA.
> - Provide NUMA support by splitting partial lists per node.
> - Better Slabcache merge support (now at around 50% of slabs)
> - List slabcache aliases if slabcaches are merged.
> - Updated descriptions /proc/slabinfo output

Seems to work fine on sparc64, sane the following build warning:

mm/slub.c:1470: warning: $,1rx(Bfor_all_slabs$,1ry(B defined but not used

That function needs CONFIG_SMP ifdef protection or similar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
