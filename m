Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0D77E6B01D7
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 21:22:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o591Mdh9028008
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Jun 2010 10:22:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E520B45DE53
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 10:22:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2F8445DE50
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 10:22:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A755B1DB803F
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 10:22:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 60BB11DB803C
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 10:22:38 +0900 (JST)
Date: Wed, 9 Jun 2010 10:18:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memory limit/quota per user
Message-Id: <20100609101821.31a06be8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikV3ZKYeZggPnuCgI7qBfN83d4d4q9JP3bsr43-@mail.gmail.com>
References: <AANLkTikV3ZKYeZggPnuCgI7qBfN83d4d4q9JP3bsr43-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010 11:27:10 +0100
Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com> wrote:

> Hello All,
> 
> Is it possible to limit memory quota per user (like disk quota) in linux ?
> 
> AFAIK, RLIMIT_* (i.e. RSS, DATA) are applicable per process not per user.
> 

please check memory cgroup and libcgroup.
(memory cgroup is for limiting memory usage per a group of processes,
 libcgroup provides automatic grouping method.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
