Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B03556B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:55:23 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1202A82C373
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:59:20 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fjTD6tACY+ez for <linux-mm@kvack.org>;
	Fri,  9 Oct 2009 09:59:20 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 825A982C64F
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:58:54 -0400 (EDT)
Date: Fri, 9 Oct 2009 09:48:38 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/3] Fix memory leak of never putback pages in mbind()
In-Reply-To: <20091009174505.12B3.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0910090946220.26484@gentwo.org>
References: <20091009100527.1284.A69D9226@jp.fujitsu.com> <20091009100708.1287.A69D9226@jp.fujitsu.com> <20091009174505.12B3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Oct 2009, KOSAKI Motohiro wrote:

> Oops, I forgot to remove unnecessary brace.
> updated patch is here.

Thats a style issue. There are other weird things in do_mbind as well
like starting a new block in the middle of another.

Having

}
{

in a program is a bit confusing. So could you do a cleanup patch for
mpol_bind? Preferably it should make it easy to read to and bring some
order to the confusing error handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
