Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 18CE46B009A
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 19:53:56 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 819223EE0AE
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:53:54 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 696E645DE6D
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:53:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5001F45DE69
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:53:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 414E31DB804F
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:53:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EFC331DB8045
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:53:53 +0900 (JST)
Date: Mon, 12 Dec 2011 09:52:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: memcg: keep root group unchanged if fail to create
 new
Message-Id: <20111212095241.e999cbf4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
References: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sun, 11 Dec 2011 09:19:12 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> If the request is not to create root group and we fail to meet it, we'd leave
> the root unchanged.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
