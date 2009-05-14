Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 249126B006A
	for <linux-mm@kvack.org>; Thu, 14 May 2009 15:58:22 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 656B482C2E4
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:12:03 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rcBjbIWXX6Kl for <linux-mm@kvack.org>;
	Thu, 14 May 2009 16:11:58 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2688082C31A
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:11:54 -0400 (EDT)
Date: Thu, 14 May 2009 15:59:07 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/4] vmscan: zone_reclaim use may_swap
In-Reply-To: <20090513120651.5882.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905141558530.1381@qirst.com>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120651.5882.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
