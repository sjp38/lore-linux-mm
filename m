Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA70bIPv015826
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 7 Nov 2008 09:37:18 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4720545DE51
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 09:37:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 23B1B45DE3E
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 09:37:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FE5A1DB803E
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 09:37:18 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C22AD1DB803A
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 09:37:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 7/7] cpu alloc: page allocator conversion
In-Reply-To: <Pine.LNX.4.64.0811060904030.3595@quilx.com>
References: <20081106115113.0D38.KOSAKI.MOTOHIRO@jp.fujitsu.com> <Pine.LNX.4.64.0811060904030.3595@quilx.com>
Message-Id: <20081107093137.F84D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  7 Nov 2008 09:37:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 6 Nov 2008, KOSAKI Motohiro wrote:
> 
> > > -		free_zone_pagesets(cpu);
> > > +		process_zones(cpu);
> > >  		break;
> >
> > Why do you drop cpu unplug code?
> 
> Because it does not do anything. Percpu areas are traditionally allocated
> for each possible cpu not for each online cpu.

Yup, Agreed.

However, if cpu-unplug happend, any pages in pcp should flush to buddy (I think).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
