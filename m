Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5339E6007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 14:56:39 -0500 (EST)
Date: Wed, 2 Dec 2009 13:56:10 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC,PATCH 1/2] dmapool: Don't warn when allowed to retry
 allocation.
In-Reply-To: <200912021520.12419.roger.oksanen@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.0912021355160.2547@router.home>
References: <200912021518.35877.roger.oksanen@cs.helsinki.fi> <200912021520.12419.roger.oksanen@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 2009, Roger Oksanen wrote:

> dmapool: Don't warn when allowed to retry allocation.

It warns after 10 attempts even when allowed to retry? Description is not
entirely accurate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
