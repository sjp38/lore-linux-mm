Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6EEF86B01F1
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 12:29:49 -0400 (EDT)
Date: Tue, 30 Mar 2010 11:29:33 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH] migrate_pages:skip migration between intersect
 nodes
In-Reply-To: <28c262361003291703i5382e342q773ffb16e3324cf5@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1003301128320.24266@router.home>
References: <1269874629-1736-1-git-send-email-lliubbo@gmail.com> <28c262361003291703i5382e342q773ffb16e3324cf5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, lee.schermerhorn@hp.com, andi@firstfloor.org, minchar.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010, Minchan Kim wrote:

> Hi, Bob
>
> On Mon, Mar 29, 2010 at 11:57 PM, Bob Liu <lliubbo@gmail.com> wrote:
> > In current do_migrate_pages(),if from_nodes and to_nodes have some
> > intersect nodes,pages in these intersect nodes will also be
> > migrated.
> > eg. Assume that, from_nodes: 1,2,3,4 to_nodes: 2,3,4,5. Then these
> > migrates will happen:
> > migrate_pages(4,5);
> > migrate_pages(3,4);
> > migrate_pages(2,3);
> > migrate_pages(1,2);
> >
> > But the user just want all pages in from_nodes move to to_nodes,
> > only migrate(1,2)(ignore the intersect nodes.) can satisfied
> > the user's request.
> >
> > I amn't sure what's migrate_page's semantic.
> > Hoping for your suggestions.
>
> I didn't see 8:migratepages Lee pointed at that time.
> The description matches current migrate_pages's behavior exactly.
>
> I agree Lee's opinion.
> Let's wait Christoph's reply what is semantic
> and why it doesn't have man page.

Manpage is part of numatools.

The intended semantic is the preservation of the relative position of the
page to the beginning of the node set. If you do not want to preserve the
relative position then just move portions of the nodes around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
