Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E85E19000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 00:37:14 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F21883EE0C0
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:37:11 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D873245DE80
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:37:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B5DB245DF48
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:37:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A57191DB803F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:37:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 72F841DB803B
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:37:11 +0900 (JST)
Date: Wed, 28 Sep 2011 13:36:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH]   fix find_next_system_ram comments
Message-Id: <20110928133621.45f936df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317132124-2820-1-git-send-email-wizarddewhite@gmail.com>
References: <1317132124-2820-1-git-send-email-wizarddewhite@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wizard <wizarddewhite@gmail.com>
Cc: linux-kernel@vger.kernel.org, rdunlap@xenotime.net, linux-mm@kvack.org

On Tue, 27 Sep 2011 22:02:04 +0800
Wizard <wizarddewhite@gmail.com> wrote:

> The purpose of find_next_system_ram() is to find a the lowest
> memory resource which contain or overlap the [res->start, res->end),
> not just contain.
> 
> In this patch, I make this comment more exact and fix one typo.
> 
> Signed-off-by: Wei Yang <wizarddewhite@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
