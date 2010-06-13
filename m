Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7F5376B01B2
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:56 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOs98022644
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A0FE45DE79
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 341ED45DE6F
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 110B21DB803A
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BE24F1DB8037
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Cleanup : change try_set_zone_oom with try_set_zonelist_oom
In-Reply-To: <1276177124-3395-1-git-send-email-minchan.kim@gmail.com>
References: <1276177124-3395-1-git-send-email-minchan.kim@gmail.com>
Message-Id: <20100613163055.615A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

> We have been used naming try_set_zone_oom and clear_zonelist_oom.
> The role of functions is to lock of zonelist for preventing parallel
> OOM. So clear_zonelist_oom makes sense but try_set_zone_oome is rather
> awkward and unmatched with clear_zonelist_oom.
> 
> Let's change it with try_set_zonelist_oom.

Ah, sure.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
