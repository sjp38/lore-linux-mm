Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id C199B6B0033
	for <linux-mm@kvack.org>; Mon, 13 May 2013 20:42:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D48173EE0C0
	for <linux-mm@kvack.org>; Tue, 14 May 2013 09:42:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C413145DE55
	for <linux-mm@kvack.org>; Tue, 14 May 2013 09:42:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1B4C45DE53
	for <linux-mm@kvack.org>; Tue, 14 May 2013 09:42:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 925CC1DB8038
	for <linux-mm@kvack.org>; Tue, 14 May 2013 09:42:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E5B7B1DB803C
	for <linux-mm@kvack.org>; Tue, 14 May 2013 09:42:07 +0900 (JST)
Message-ID: <51918846.7090006@jp.fujitsu.com>
Date: Tue, 14 May 2013 09:41:42 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 0/3] memcg: simply lock of page stat accounting
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

If you want to rewrite all things and make memcg cleaner, I don't stop it.
But, how about starting with this simeple one for your 1st purpose ? 
doesn't work ? dirty ?

== this patch is untested. ==
 
