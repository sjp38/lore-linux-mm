Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94E228D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 03:16:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BEACB3EE0C1
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 16:15:59 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A699045DED5
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 16:15:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F1CA45DF4A
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 16:15:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8198AE08001
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 16:15:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 49BD2E18003
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 16:15:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] kstaled: page_referenced_kstaled() and supporting infrastructure.
In-Reply-To: <1302132162.8184.517.camel@nimitz>
References: <1301042635-11180-3-git-send-email-walken@google.com> <1302132162.8184.517.camel@nimitz>
Message-Id: <20110407161620.3A0B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  7 Apr 2011 16:15:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org

> On Fri, 2011-03-25 at 01:43 -0700, Michel Lespinasse wrote:
> > +PAGEFLAG(Young, young)
> > +
> > +PAGEFLAG(Idle, idle)
> > +
> > +static inline void set_page_young(struct page *page)
> > +{
> > +       if (!PageYoung(page))
> > +               SetPageYoung(page);
> > +}
> > +
> > +static inline void clear_page_idle(struct page *page)
> > +{
> > +       if (PageIdle(page))
> > +               ClearPageIdle(page);
> > +} 
> 
> Is it time for a CONFIG_X86_32_STRUCT_PAGE_IS_NOW_A_BLOATED_BIG config
> option?  If folks want these kinds of features, then they need to suck
> it up and make their 'struct page' 36 bytes.  Any of these new page
> flags features could:
> 
> 	config EXTENDED_PAGE_FLAGS
> 		depends on 64BIT || X86_32_STRUCT_PAGE_IS_NOW_A_BLOATED_BIG
> 
> 	config KSTALED
> 		depends on EXTENDED_PAGE_FLAGS
> 
> And then we can wrap the "enum pageflags" entries for them in #ifdefs,
> along with making page->flags a u64 when
> X86_32_STRUCT_PAGE_IS_NOW_A_BLOATED_BIG is set.

Right.

x86_32 has no left space for new flags and 36byte struct page is unacceptable.
Hmm...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
