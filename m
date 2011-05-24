Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8B12C6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 23:11:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F15FE3EE0AE
	for <linux-mm@kvack.org>; Tue, 24 May 2011 12:11:26 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4C3945DF31
	for <linux-mm@kvack.org>; Tue, 24 May 2011 12:11:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BFD7F45DF2F
	for <linux-mm@kvack.org>; Tue, 24 May 2011 12:11:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B1B6AE08001
	for <linux-mm@kvack.org>; Tue, 24 May 2011 12:11:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EA9EEF8001
	for <linux-mm@kvack.org>; Tue, 24 May 2011 12:11:26 +0900 (JST)
Message-ID: <4DDB21D8.3090400@jp.fujitsu.com>
Date: Tue, 24 May 2011 12:11:20 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram
 internally
References: <4DD61F80.1020505@jp.fujitsu.com>	<4DD6204D.5020109@jp.fujitsu.com> <BANLkTinpX59NnwsJVQZNTgt_6X3DVK9WLg@mail.gmail.com> <4DDB0D93.5070005@jp.fujitsu.com>
In-Reply-To: <4DDB0D93.5070005@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

> ok, removed.

I'm sorry. previous patch has white space damage.
Let's retry send it.
