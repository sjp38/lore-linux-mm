Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 29F616B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 03:02:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 29A623EE0C0
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:02:18 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EB74745DD78
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:02:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D2E4E45DE52
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:02:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C06D41DB803F
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:02:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AD5A1DB803A
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:02:17 +0900 (JST)
Message-ID: <4FF146F7.7060703@jp.fujitsu.com>
Date: Mon, 02 Jul 2012 16:00:07 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] memcg: update cgroup memory document
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com> <1340881055-5511-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1340881055-5511-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

(2012/06/28 19:57), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Document cgroup dirty/writeback memory statistics.
> 
> The implementation for these new interface routines come in a series
> of following patches.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
