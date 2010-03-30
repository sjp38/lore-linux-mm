Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9A3016B01F0
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 12:28:35 -0400 (EDT)
Date: Tue, 30 Mar 2010 11:28:21 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH] migrate_pages:skip migration between intersect
 nodes
In-Reply-To: <20100330083638.8E87.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003301127410.24266@router.home>
References: <1269874629-1736-1-git-send-email-lliubbo@gmail.com> <1269876708.13829.30.camel@useless.americas.hpqcorp.net> <20100330083638.8E87.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, minchar.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010, KOSAKI Motohiro wrote:

> > I believe that the current code matches the intended semantics.  I can't
> > find a man pages for the migrate_pages() system call, but the
> > migratepages(8) man page says:
> >
> > "If  multiple  nodes  are specified for from-nodes or to-nodes then an
> > attempt is made to preserve the relative location of each page in each
> > nodeset."
>
> Offtopic>
> Christoph, Why migrate_pages(2) doesn't have man pages? Is it unrecommended
> syscall?

The manpage is in the numatools package3.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
