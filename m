Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 039476B007E
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 18:53:53 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o28Nrpec012885
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Mar 2010 08:53:51 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0527845DE4F
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 08:53:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DFC5545DE4E
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 08:53:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C9AF71DB8012
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 08:53:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 86D841DB8014
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 08:53:47 +0900 (JST)
Date: Tue, 9 Mar 2010 08:50:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: sync_mm_rss() issues
Message-Id: <20100309085012.46c28722.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <30859.1268056796@redhat.com>
References: <30859.1268056796@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 08 Mar 2010 13:59:56 +0000
David Howells <dhowells@redhat.com> wrote:

> 
> There are a couple of issues with sync_mm_rss(), as added by patch:
> 
> 	commit 34e55232e59f7b19050267a05ff1226e5cd122a5
> 	Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 	Date:   Fri Mar 5 13:41:40 2010 -0800
> 	Subject: mm: avoid false sharing of mm_counter
> 
>  (1) You haven't implemented it for NOMMU mode.  What's the right way to do
>      this?  Just give an empty function?
> 
Ah, sorry. I'll prepare empty function immediately. But I have no NOMMU
enviroment...


>  (2) linux/mm.h should carry the empty function as an inline when
>      CONFIG_SPLIT_RSS_COUNTING=n, rather than it being defined as an empty
>      function in mm/memory.c.
> 

ok.

please wait..

Sorry,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
