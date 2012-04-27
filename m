Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 849796B0044
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 19:09:22 -0400 (EDT)
Date: Fri, 27 Apr 2012 16:09:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm V3] do_migrate_pages() calls migrate_to_node() even
 if task is already on a correct node
Message-Id: <20120427160919.086dff9d.akpm@linux-foundation.org>
In-Reply-To: <CAHGf_=qLX7gofwHoSKpHLp7nvD6qJtHbmYzAR0UQ42JbfnYerw@mail.gmail.com>
References: <4F998FDE.5020104@redhat.com>
	<CAHGf_=qLX7gofwHoSKpHLp7nvD6qJtHbmYzAR0UQ42JbfnYerw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: lwoodman@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux.com>, Motohiro Kosaki <mkosaki@redhat.com>

On Thu, 26 Apr 2012 21:14:16 -0400
KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Motohiro Kosaki <mkosaki@redhat.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

umm, help.  What is your preferred email address ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
