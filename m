Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A17226B0062
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 05:27:19 -0500 (EST)
Date: Tue, 17 Nov 2009 10:29:03 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2/7] mmc: Don't use PF_MEMALLOC
Message-ID: <20091117102903.7cb45ff3@lxorguk.ukuu.org.uk>
In-Reply-To: <20091117161711.3DDA.A69D9226@jp.fujitsu.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
	<20091117161711.3DDA.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mmc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 2009 16:17:50 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
> memory, anyone must not prevent it. Otherwise the system cause
> mysterious hang-up and/or OOM Killer invokation.

So now what happens if we are paging and all our memory is tied up for
writeback to a device or CIFS etc which can no longer allocate the memory
to complete the write out so the MM can reclaim ?

Am I missing something or is this patch set not addressing the case where
the writeback thread needs to inherit PF_MEMALLOC somehow (at least for
the I/O in question and those blocking it)

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
