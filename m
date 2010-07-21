Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8B3DA6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 09:34:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6LDYDKS001340
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 21 Jul 2010 22:34:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 85BB445DE4E
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6317F45DE55
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 359AA1DB803B
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD72AE08002
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 22:34:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Add trace points to mmap, munmap, and brk
In-Reply-To: <f6a595dfac141397dcac8c29475be73d10f5248c.1279558781.git.emunson@mgebm.net>
References: <cover.1279558781.git.emunson@mgebm.net> <f6a595dfac141397dcac8c29475be73d10f5248c.1279558781.git.emunson@mgebm.net>
Message-Id: <20100721223359.8710.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 21 Jul 2010 22:34:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This patch adds trace points to mmap, munmap, and brk that will report
> relevant addresses and sizes before each function exits successfully.
> 
> Signed-off-by: Eric B Munson <emunson@mgebm.net>

I don't think this is good idea. if you need syscall result, you should 
use syscall tracer. IOW, This tracepoint bring zero information.

Please see perf_event_mmap() usage. Our kernel manage adress space by
vm_area_struct. we need to trace it if we need to know what kernel does.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
