Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6ACE66B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:48:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2B12F82C444
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:51:59 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tP7EPUEpf70h for <linux-mm@kvack.org>;
	Fri,  9 Oct 2009 09:51:59 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5AD0E82C13F
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:51:32 -0400 (EDT)
Date: Fri, 9 Oct 2009 09:41:16 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/3] Fix memory leak of never putback pages in mbind()
In-Reply-To: <20091009100708.1287.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0910090940500.26484@gentwo.org>
References: <20091009100527.1284.A69D9226@jp.fujitsu.com> <20091009100708.1287.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Oct 2009, KOSAKI Motohiro wrote:

> if mbind() receive invalid address, do_mbind makes leaked page.
> following test program detect its leak.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
