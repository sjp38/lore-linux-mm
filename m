Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 23D0A6B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 09:56:44 -0500 (EST)
Date: Thu, 14 Jan 2010 08:56:38 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix mbind vma merge problem
In-Reply-To: <20100114154720.6732.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1001140854440.14164@router.home>
References: <20100114154720.6732.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Cannot find any fault with this but then I am not too familiar with the
whole vma merging thing.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
