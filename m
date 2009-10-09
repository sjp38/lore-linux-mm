Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 766FA6B005A
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:51:16 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C39E982C3DD
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:55:12 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fSU1eXNSVQeG for <linux-mm@kvack.org>;
	Fri,  9 Oct 2009 09:55:08 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 732B882C4A5
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:55:03 -0400 (EDT)
Date: Fri, 9 Oct 2009 09:44:47 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] Fix memory leak of do_mbind()
In-Reply-To: <20091009100837.128A.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0910090943130.26484@gentwo.org>
References: <20091009100527.1284.A69D9226@jp.fujitsu.com> <20091009100837.128A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Oct 2009, KOSAKI Motohiro wrote:

> If migrate_prep is failed, new variable is leaked.
> This patch fixes it.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
