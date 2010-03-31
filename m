Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A3AAA6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 10:17:45 -0400 (EDT)
Date: Wed, 31 Mar 2010 09:17:30 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH] migrate_pages:skip migration between intersect
 nodes
In-Reply-To: <cf18f8341003301836i248d716as8d90c130790194ff@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1003310914290.17298@router.home>
References: <1269874629-1736-1-git-send-email-lliubbo@gmail.com>  <28c262361003291703i5382e342q773ffb16e3324cf5@mail.gmail.com>  <alpine.DEB.2.00.1003301128320.24266@router.home> <cf18f8341003301836i248d716as8d90c130790194ff@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, lee.schermerhorn@hp.com, andi@firstfloor.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, Bob Liu wrote:

> > The intended semantic is the preservation of the relative position of the
> > page to the beginning of the node set. If you do not want to preserve the
> > relative position then just move portions of the nodes around.
> >
>
> Hmm.,
> Sorry I still haven't understand your mention :-)
>
> My concern was why move the pages in the intersect nodes.I think skipping
> this migration we can also satisfy the user's request.
> In the above semantic, I  haven't got the result.

No skipping does *not* satisfy the users request since the relative
position of the page from the beginning of the nodesset is not
preserved.

You end up with a mess without this requirement. F.e. if you use page
migration (or cpuset automigration) to shift an application running on 10
nodes up by two nodes to make a hole that would allow you to run another
application on the lower nodes. Applications place pages intentionally on
certain nodes to be able to manage memory distances.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
