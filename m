Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6BFA66B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 10:44:41 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CA98482C38A
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 11:12:18 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ymiCjWhZxaeh for <linux-mm@kvack.org>;
	Wed,  8 Jul 2009 11:12:18 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 40A9182C392
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 11:12:15 -0400 (EDT)
Date: Wed, 8 Jul 2009 10:53:38 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: RE: Performance degradation seen after using one list for
 hot/coldpages.
In-Reply-To: <98062A42B4E040F4861C78D172E2499B@sisodomain.com>
Message-ID: <alpine.DEB.1.10.0907081051570.26162@gentwo.org>
References: <20626261.51271245670323628.JavaMail.weblogic@epml20> <20090622165236.GE3981@csn.ul.ie> <20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com> <20090629091542.GC28597@csn.ul.ie> <98062A42B4E040F4861C78D172E2499B@sisodomain.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Narayanan Gopalakrishnan <narayanan.g@samsung.com>
Cc: 'Mel Gorman' <mel@csn.ul.ie>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 2009, Narayanan Gopalakrishnan wrote:

> We have done some stress testing using fsstress (LTP).
> This patch seems to work fine with our OMAP based targets.
> Can we have this merged?

Please post the patch that you tested. I am a bit confused due to
topposting. There were several outstanding issues in the message you
included.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
