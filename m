Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 818BE6B0092
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 00:46:22 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 11E113EE0C0
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:46:21 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBD1445DEB3
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:46:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D21FF45DEAD
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:46:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C538B1DB803E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:46:20 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D35B1DB8038
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 14:46:20 +0900 (JST)
Date: Thu, 8 Mar 2012 14:44:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: revise the position of threshold index while
 unregistering event
Message-Id: <20120308144448.889337cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>
References: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

On Tue,  6 Mar 2012 20:12:23 +0800
Sha Zhengju <handai.szj@gmail.com> wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Index current_threshold should point to threshold just below or equal to usage.
> See below:
> http://www.spinics.net/lists/cgroups/msg00844.html
> 
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Thank you for resending.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
