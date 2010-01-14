Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A78B46B006A
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 19:31:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0E0V52e019684
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 09:31:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DE7C845DE64
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 09:31:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC6BA45DE62
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 09:31:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A3AF31DB803A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 09:31:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 478511DB803F
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 09:31:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v5] add MAP_UNLOCKED mmap flag
In-Reply-To: <20100113093119.GT7549@redhat.com>
References: <20100113093119.GT7549@redhat.com>
Message-Id: <20100114092845.D719.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Jan 2010 09:31:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> If application does mlockall(MCL_FUTURE) it is no longer possible to mmap
> file bigger than main memory or allocate big area of anonymous memory
> in a thread safe manner. Sometimes it is desirable to lock everything
> related to program execution into memory, but still be able to mmap
> big file or allocate huge amount of memory and allow OS to swap them on
> demand. MAP_UNLOCKED allows to do that.
>  
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---
> 
> I get reports that people find this useful, so resending.

This description is still wrong. It doesn't describe why this patch is useful.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
