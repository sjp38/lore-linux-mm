Date: Sat, 24 Feb 2007 16:14:48 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: SLUB: The unqueued Slab allocator
In-Reply-To: <20070224193322.GA17276@lazybastard.org>
Message-ID: <Pine.LNX.4.64.0702241613520.4891@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com>
 <20070224142835.4c7a3207.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0702232145340.1872@schroedinger.engr.sgi.com>
 <20070223.215439.92580943.davem@davemloft.net>
 <Pine.LNX.4.64.0702240931030.3912@schroedinger.engr.sgi.com>
 <20070224193322.GA17276@lazybastard.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-637110898-1172362488=:4891"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?utf-8?B?SsO2cm4=?= Engel <joern@lazybastard.org>
Cc: David Miller <davem@davemloft.net>, kamezawa.hiroyu@jp.fujitsu.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---1700579579-637110898-1172362488=:4891
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 24 Feb 2007, J=F6rn Engel wrote:

> How much of a gain is the merging anyway?  Once you start having
> explicit whitelists or blacklists of pools that can be merged, one can
> start to wonder if the result is worth the effort.

It eliminates 50% of the slab caches. Thus it reduces the management=20
overhead by half.


---1700579579-637110898-1172362488=:4891--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
