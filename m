Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DF29D6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 02:51:45 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S6qWqN006667
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 28 Apr 2009 15:52:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A10445DE51
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 15:52:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 64C9A45DE50
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 15:52:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C81BE08001
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 15:52:32 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E610C1DB8042
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 15:52:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Swappiness vs. mmap() and interactive response
In-Reply-To: <20090428063625.GA17785@eskimo.com>
References: <20090428143019.EBBF.A69D9226@jp.fujitsu.com> <20090428063625.GA17785@eskimo.com>
Message-Id: <20090428154835.EBC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 15:52:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Elladan <elladan@eskimo.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> 3. cache limitation of memcgroup solve this problem?
> 
> I was unable to get this to work -- do you have some documentation handy?

Do you have kernel source tarball?
Documentation/cgroups/memory.txt explain usage kindly.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
