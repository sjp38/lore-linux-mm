Date: Tue, 18 Nov 2008 16:56:57 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH mmotm] memcg: avoid using buggy kmap at swap_cgroup 
In-Reply-To: <Pine.LNX.4.64.0811181629070.417@blonde.site>
Message-ID: <Pine.LNX.4.64.0811181653290.3506@blonde.site>
References: <20081118180721.cb2fe744.nishimura@mxp.nes.nec.co.jp><20081118182637.97ae0e48.kamezawa.hiroyu@jp.fujitsu.com><20081118192135.300803ec.nishimura@mxp.nes.nec.co.jp><20081118210838.c99887fd.nishimura@mxp.nes.nec.co.jp><Pine.LNX.4.64.0811181234430.9680@blonde.site>
    <20081119001756.0a31b11e.d-nishimura@mtf.biglobe.ne.jp>
 <6023.10.75.179.61.1227024730.squirrel@webmail-b.css.fujitsu.com>
 <Pine.LNX.4.64.0811181629070.417@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, LiZefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Nov 2008, Hugh Dickins wrote:
> On Wed, 19 Nov 2008, KAMEZAWA Hiroyuki wrote:
> 
> >  2. later, add kmap_atomic + HighMem buffer support in explicit style.
> >     maybe KM_BOUNCE_READ...can be used.....
> 
> It's hardly appropriate (there's no bouncing here), and you could only
> use it if you disable interrupts.  Oh, you do disable interrupts:
> why's that?

In fact, why do you even need the spinlock?  I can see that you would
need it if in future you reduce the size of the elements of the array
from pointers; but at present, aren't you already in trouble if there's
a race on the pointer?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
