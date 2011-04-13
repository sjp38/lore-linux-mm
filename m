Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F440900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 02:44:40 -0400 (EDT)
Received: by fxm18 with SMTP id 18so382759fxm.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 23:44:37 -0700 (PDT)
Date: Wed, 13 Apr 2011 09:44:32 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
Message-ID: <20110413064432.GA4098@p183>
References: <BANLkTinLdWB+ON=TY=KHyzsrC8gC5bXg7Q@mail.gmail.com>
 <1302646024.28876.52.camel@pasglop>
 <20110413091301.41E1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110413091301.41E1.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

On Wed, Apr 13, 2011 at 09:13:03AM +0900, KOSAKI Motohiro wrote:
> > On Tue, 2011-04-12 at 14:06 +0300, Alexey Dobriyan wrote:
> > > On Tue, Apr 12, 2011 at 10:12 AM, KOSAKI Motohiro
> > > <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > > After next year? All developers don't have to ignore compiler warnings!
> > > 
> > > At least add vm_flags_t which is sparse-checked, just like we do with gfp_t.
> > > 
> > > VM_SAO is ppc64 only, so it could be moved into high part,
> > > freeing 1 bit?
> > 
> > My original series did use a type, I don't know what that was dropped,
> > it made conversion easier imho.
> 
> Yes, I take Hugh's version because vm_flags_t is ugly to me. And arch 
> dependent variable size is problematic.

Who said it should have arch-dependent size?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
