Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A646D90008D
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 03:05:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 014333EE0C7
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:04:56 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D911845DD74
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:04:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C257945DE61
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:04:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A8E941DB8043
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:04:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F1531DB803C
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:04:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
In-Reply-To: <20110413064432.GA4098@p183>
References: <20110413091301.41E1.A69D9226@jp.fujitsu.com> <20110413064432.GA4098@p183>
Message-Id: <20110413160455.D72E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Apr 2011 16:04:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

> On Wed, Apr 13, 2011 at 09:13:03AM +0900, KOSAKI Motohiro wrote:
> > > On Tue, 2011-04-12 at 14:06 +0300, Alexey Dobriyan wrote:
> > > > On Tue, Apr 12, 2011 at 10:12 AM, KOSAKI Motohiro
> > > > <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > > > After next year? All developers don't have to ignore compiler warnings!
> > > > 
> > > > At least add vm_flags_t which is sparse-checked, just like we do with gfp_t.
> > > > 
> > > > VM_SAO is ppc64 only, so it could be moved into high part,
> > > > freeing 1 bit?
> > > 
> > > My original series did use a type, I don't know what that was dropped,
> > > it made conversion easier imho.
> > 
> > Yes, I take Hugh's version because vm_flags_t is ugly to me. And arch 
> > dependent variable size is problematic.
> 
> Who said it should have arch-dependent size?

Ben's patch had arch-dependent size.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
