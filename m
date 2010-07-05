Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 918666B01AC
	for <linux-mm@kvack.org>; Sun,  4 Jul 2010 20:21:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o650LNo5023553
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 5 Jul 2010 09:21:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6514545DE51
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 09:21:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CA25045DE54
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 09:21:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2196C1DB8016
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 09:21:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 637121DB801C
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 09:21:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [ATTEND][LSF/VM TOPIC] mmap_sem scalability and edge cases
In-Reply-To: <20100702113627.GC11732@laptop>
References: <AANLkTil6P5PNAYOplauoHiOgno-wrByOSAhS494-DAyJ@mail.gmail.com> <20100702113627.GC11732@laptop>
Message-Id: <20100705091731.CC91.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  5 Jul 2010 09:21:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lsf10-pc@lists.linuxfoundation.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Michel,

> > Solutions:
> > We have a number of patches that partially address these issues:
> > - releasing mmap_sem when a page fault requires a disk read of the backing
> > file
> > - reducing mmap_sem hold time during mlock operations
> > - unfair read acquire for the OOMing threads

At least, personally I'd like to merge your unfair rwsem + appling it for
OOMing thread. If you've alredy finished to make the patch, can you 
please post it on LKML?



> > We don't currently have patches for, but would be interested in:
> > - releasing mmap_sem when a page fault causes a disk wait due to memory
> > reclaim (if it's possible to do so while avoiding starvation...)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
