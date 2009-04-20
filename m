Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3C61D5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 13:08:34 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D3E3582C5DA
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 13:18:58 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LULTWhDYIy7R for <linux-mm@kvack.org>;
	Mon, 20 Apr 2009 13:18:58 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A047F82C5CA
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 13:18:48 -0400 (EDT)
Date: Mon, 20 Apr 2009 13:00:34 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: AIM9 from 2.6.22 to 2.6.29
In-Reply-To: <20090418154207.1260.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0904201300140.1585@qirst.com>
References: <alpine.DEB.1.10.0904161616001.17864@qirst.com> <20090418154207.1260.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 18 Apr 2009, KOSAKI Motohiro wrote:

> > Here is a list of AIM9 results for all kernels between 2.6.22 2.6.29:
> >
> > Significant regressions:
> >
> > creat-clo
> > page_test
>
> I'm interest to it.
> How do I get AIM9 benchmark?

Checkout reaim9 on sourceforge.
>
> and, Can you compare CONFIG_UNEVICTABLE_LRU is y and n?


Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
