Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DC7C0900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 20:09:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D9F2B3EE0AE
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:09:17 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C247F45DE92
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:09:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A918645DE88
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:09:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D312E38001
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:09:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 673B21DB8049
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:09:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] tile: replace mm->cpu_vm_mask with mm_cpumask()
In-Reply-To: <4DAC37E7.5010809@tilera.com>
References: <20110418211914.9361.A69D9226@jp.fujitsu.com> <4DAC37E7.5010809@tilera.com>
Message-Id: <20110419090923.9369.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Apr 2011 09:09:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

> On 4/18/2011 8:18 AM, KOSAKI Motohiro wrote:
> > We plan to change mm->cpu_vm_mask definition later. Thus, this patch convert
> > it into proper macro.
> >
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Chris Metcalf <cmetcalf@tilera.com>
> 
> Thanks; I wasn't aware of this macro.  I'll take this change into my tree
> unless you would like to push it.

Thanks. 

I hope this patch route  your tree. I don't want to push patch 3/3 to linus-tree
until all architecture finish to convert mm_cpumask().


> > Chris, I couldn't get cross compiler for tile. thus I hope you check it carefully.
> 
> The toolchain support is currently only available from Tilera (at
> http://www.tilera.com/scm/) but we are in the process of cleaning it up to
> push it up to the community.

Thank you, too.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
