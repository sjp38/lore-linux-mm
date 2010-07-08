Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BFE786B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 16:59:23 -0400 (EDT)
Date: Thu, 8 Jul 2010 13:59:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] reduce stack usage of node_read_meminfo()
Message-Id: <20100708135916.590fc493.akpm@linux-foundation.org>
In-Reply-To: <20100708194107.CD45.A69D9226@jp.fujitsu.com>
References: <20100708181629.CD3C.A69D9226@jp.fujitsu.com>
	<20100708194107.CD45.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu,  8 Jul 2010 19:41:57 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Grr, I did sent old ver. right patch is here ;-)
> sorry.

oop, there it is.  Did you check the output carefully?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
