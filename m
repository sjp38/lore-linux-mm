Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 5F56D6B00EA
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:30:47 -0400 (EDT)
Date: Thu, 22 Mar 2012 14:30:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
In-Reply-To: <4F6B7854.1040203@redhat.com>
Message-ID: <alpine.DEB.2.00.1203221421570.25011@router.home>
References: <4F6B6BFF.1020701@redhat.com> <4F6B7358.60800@gmail.com> <alpine.DEB.2.00.1203221348470.25011@router.home> <4F6B7854.1040203@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>

On Thu, 22 Mar 2012, Larry Woodman wrote:

> > Application may manage their locality given a range of nodes and each of
> > the x .. x+n nodes has their particular purpose.
> So to be clear on this, in that case the intention would be move 3 to 4, 4 to
> 5 and 5 to 6
> to keep the node ordering the same?

Yup. Have a look at do_migrate_pages and the descrition in the comment by
there by Paul Jackson.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
