Date: Sat, 24 Feb 2007 19:33:23 +0000
From: =?utf-8?B?SsO2cm4=?= Engel <joern@lazybastard.org>
Subject: Re: SLUB: The unqueued Slab allocator
Message-ID: <20070224193322.GA17276@lazybastard.org>
References: <Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com> <20070224142835.4c7a3207.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0702232145340.1872@schroedinger.engr.sgi.com> <20070223.215439.92580943.davem@davemloft.net> <Pine.LNX.4.64.0702240931030.3912@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.64.0702240931030.3912@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: David Miller <davem@davemloft.net>, kamezawa.hiroyu@jp.fujitsu.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 February 2007 09:32:49 -0800, Christoph Lameter wrote:
> 
> If that is a problem for particular object pools then we may be able to 
> except those from the merging.

How much of a gain is the merging anyway?  Once you start having
explicit whitelists or blacklists of pools that can be merged, one can
start to wonder if the result is worth the effort.

JA?rn

-- 
Joern's library part 6:
http://www.gzip.org/zlib/feldspar.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
