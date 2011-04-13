Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E683F900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 20:13:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 016133EE0BC
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 09:13:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD3F545DE59
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 09:13:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C50DB45DE58
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 09:13:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA4DEE38001
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 09:13:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 72876E08005
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 09:13:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
In-Reply-To: <1302646024.28876.52.camel@pasglop>
References: <BANLkTinLdWB+ON=TY=KHyzsrC8gC5bXg7Q@mail.gmail.com> <1302646024.28876.52.camel@pasglop>
Message-Id: <20110413091301.41E1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 13 Apr 2011 09:13:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

> On Tue, 2011-04-12 at 14:06 +0300, Alexey Dobriyan wrote:
> > On Tue, Apr 12, 2011 at 10:12 AM, KOSAKI Motohiro
> > <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > After next year? All developers don't have to ignore compiler warnings!
> > 
> > At least add vm_flags_t which is sparse-checked, just like we do with gfp_t.
> > 
> > VM_SAO is ppc64 only, so it could be moved into high part,
> > freeing 1 bit?
> 
> My original series did use a type, I don't know what that was dropped,
> it made conversion easier imho.

Yes, I take Hugh's version because vm_flags_t is ugly to me. And arch 
dependent variable size is problematic. Because Almost all driver developers
only test their code on x86. Also, I don't want to add hidden ifdef into mm
code.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
