Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 36B2C8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 21:23:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5C5B03EE0C0
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:23:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4075445DE8F
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:23:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2843E45DE93
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:23:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B9151DB8038
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:23:37 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DAACBE08001
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:23:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards
In-Reply-To: <alpine.DEB.2.00.1104191657030.26867@router.home>
References: <1303249716.11237.26.camel@mulgrave.site> <alpine.DEB.2.00.1104191657030.26867@router.home>
Message-Id: <20110420102314.4604.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Apr 2011 10:23:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, James Bottomley <James.Bottomley@HansenPartnership.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

> On Tue, 19 Apr 2011, James Bottomley wrote:
> 
> > > Which part of me telling you that you will break lots of other things in
> > > the core kernel dont you get?
> >
> > I get that you tell me this ... however, the systems that, according to
> > you, should be failing to get to boot prompt do, in fact, manage it.
> 
> If you dont use certain subsystems then it may work. Also do you run with
> debuggin on.
> 
> The following patch is I think what would be needed to fix it.

I'm worry about this patch. A lot of mm code assume !NUMA systems 
only have node 0. Not only SLUB.

I'm not sure why this unfortunate mismatch occur. but I think DISCONTIG
hacks makes less sense. Can we consider parisc turn NUMA on instead?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
