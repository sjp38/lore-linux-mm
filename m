Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6474C6B0044
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 18:46:29 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBANkQ6x031766
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 11 Dec 2009 08:46:27 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A3FA45DE52
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:46:26 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A5BC45DE4E
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:46:26 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D86AE1800B
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:46:26 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E88491DB8040
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:46:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v2  4/8] Replace page_referenced() with wipe_page_reference()
In-Reply-To: <4B20EF88.7050402@redhat.com>
References: <20091210163123.255C.A69D9226@jp.fujitsu.com> <4B20EF88.7050402@redhat.com>
Message-Id: <20091211082410.257D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 11 Dec 2009 08:46:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: lwoodman@redhat.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> KOSAKI Motohiro wrote:
> > @@ -578,7 +577,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >
> > +		struct page_reference_context refctx = {
> > +			.is_page_locked = 1,
> >
> >   *
> > @@ -1289,7 +1291,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >
> > +		struct page_reference_context refctx = {
> > +			.is_page_locked = 0,
> > +		};
> > +
> >   
> are these whole structs properly initialized on the kernel stack?

Yes. C spec says

3.5.7 Initialization

Syntax

          initializer:
                  assignment-expression
                  {  initializer-list } 
                  {  initializer-list , }

          initializer-list:
                  initializer
                  initializer-list ,  initializer
(snip)

   If there are fewer initializers in a list than there are members of
an aggregate, the remainder of the aggregate shall be initialized
implicitly the same as objects that have static storage duration.

Referenced to
  Draft ANSI C Standard (ANSI X3J11/88-090) (May 13, 1988) http://flash-gordon.me.uk/ansi.c.txt


Probably, google "{0}" help your understand to initializer in C.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
