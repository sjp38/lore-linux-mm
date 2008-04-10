Date: Thu, 10 Apr 2008 10:33:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/9] Page flags V3: Cleanup and reorg
In-Reply-To: <Pine.LNX.4.64.0804031149060.7108@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0804101033220.11823@schroedinger.engr.sgi.com>
References: <20080401200019.47892504.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804021026400.26938@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0804022125001.1684@schroedinger.engr.sgi.com>
 <20080402.222542.106676535.davem@davemloft.net>
 <Pine.LNX.4.64.0804031149060.7108@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, jeremy@goop.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ping? Is this okay Dave?

On Thu, 3 Apr 2008, Christoph Lameter wrote:

> On Wed, 2 Apr 2008, David Miller wrote:
> 
> > No this won't work, see PG_dcache_cpu_shift in arch/sparc64/mm/init.c,
> > the code currently statically puts the cpu number of the the cpu which
> > potentially dirtied the page in the D-cache at bit 32 of the page
> > flags and onwards.
> 
> That looks fine to me. If we use less than 32 page flags then bits 32 to 
> the beginning of the zone field are still available.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
