Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3F45D6B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 06:26:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o36AQ2jc030344
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Apr 2010 19:26:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7105545DE4F
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 19:26:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F00C45DE4D
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 19:26:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 34F791DB803B
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 19:26:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF70C1DB803E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 19:26:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Arch specific mmap attributes (Was: mprotect pgprot handling weirdness)
In-Reply-To: <1270539044.13812.65.camel@pasglop>
References: <20100406151751.7E4E.A69D9226@jp.fujitsu.com> <1270539044.13812.65.camel@pasglop>
Message-Id: <20100406185246.7E63.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  6 Apr 2010 19:26:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Ok, I see. No biggie. The main deal remains how we want to do that
> inside the kernel :-) I think the less horrible options here are
> to either extend vm_flags to always be 64-bit, or add a separate
> vm_map_attributes flag, and add the necessary bits and pieces to
> prevent merge accross different attribute vma's.

vma->vm_flags already have VM_SAO. Why do we need more flags?
At least, I dislike to add separate flags member into vma.
It might introduce unnecessary messy into vma merge thing.



> The more I try to hack it into vm_page_prot, the more I hate that
> option.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
