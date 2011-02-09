Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3EF458D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 18:56:46 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7387C3EE0BC
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:56:44 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A23545DE58
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:56:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 418CF45DE55
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:56:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32A6BE08005
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:56:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F15A4E08002
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:56:43 +0900 (JST)
Date: Thu, 10 Feb 2011 08:50:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 0/4] memcg: operate on page quantities internally
Message-Id: <20110210085034.a6c5d703.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
References: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  9 Feb 2011 12:01:49 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hi,
> 
> this patch set converts the memcg charge and uncharge paths to operate
> on multiples of pages instead of bytes.  It already was a good idea
> before, but with the merge of THP we made a real mess by specifying
> huge pages alternatingly in bytes or in number of regular pages.
> 
> If I did not miss anything, this should leave only res_counter and
> user-visible stuff in bytes.  The ABI probably won't change, so next
> up is converting res_counter to operate on page quantities.
> 

Hmm, I think this should be done but think this should be postphoned, too.
Because, IIUC, some guys will try to discuss charging against kernel objects
in the next mm-summit. IMHO, it will be done against PAGE not against
Object even if we do kernel object accouting. So this patch is okay for me.
But I think it's better to go ahead after we confirm the way we go.
How do you think ?

Anyway, I welcome this patch.

Thanks,
-Kame



> 	Hannes
> 
>  include/linux/sched.h |    4 +-
>  mm/memcontrol.c       |  157 ++++++++++++++++++++++++-------------------------
>  2 files changed, 78 insertions(+), 83 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
