Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 13FE36B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 14:17:53 -0400 (EDT)
Date: Tue, 24 Apr 2012 13:17:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm V2] do_migrate_pages() calls migrate_to_node() even
 if task is already on a correct node
In-Reply-To: <4F96DFE0.6040306@redhat.com>
Message-ID: <alpine.DEB.2.00.1204241317170.26005@router.home>
References: <4F96CDE1.5000909@redhat.com> <4F96D27A.2050005@gmail.com> <4F96DFE0.6040306@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <alpine.DEB.2.00.1204241317172.26005@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Motohiro Kosaki <mkosaki@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 24 Apr 2012, Larry Woodman wrote:

> How does this look:

Could you please send the patches inline? Its difficult to quote the
attachment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
