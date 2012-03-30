Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0981D6B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 16:49:14 -0400 (EDT)
Date: Fri, 30 Mar 2012 15:49:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
In-Reply-To: <4F75EDC3.7050104@redhat.com>
Message-ID: <alpine.DEB.2.00.1203301548070.27435@router.home>
References: <4F6B6BFF.1020701@redhat.com> <4F6B7358.60800@gmail.com> <alpine.DEB.2.00.1203221348470.25011@router.home> <4F6B7854.1040203@redhat.com> <alpine.DEB.2.00.1203221421570.25011@router.home> <4F74A344.7070805@redhat.com> <4F74BB67.30703@gmail.com>
 <alpine.DEB.2.00.1203301113530.22502@router.home> <4F75EDC3.7050104@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>

On Fri, 30 Mar 2012, Larry Woodman wrote:

> of nodes.
> >   I would think that the 1-1 movement
> > is only useful to do if the number of nodes in both the destination and
> > the source is the same.
> Agreed, thats exactly what this patch does.  are you OK with this change
> then???

Please add to the patch description some explanation how this patch
changes the way page migration does things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
