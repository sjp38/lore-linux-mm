Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 682926B007E
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:44:14 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BA5F93EE0BD
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:44:12 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BEFF45DE54
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:44:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 842C445DE4F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:44:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 67BD31DB8043
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:44:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AC281DB803B
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:44:12 +0900 (JST)
Date: Tue, 28 Feb 2012 09:42:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 11/21] mm: move page-to-lruvec translation upper
Message-Id: <20120228094245.2fc69484.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135233.12988.8130.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135233.12988.8130.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:52:33 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> move page_lruvec() out of add_page_to_lru_list() and del_page_from_lru_list()
> switch its first argument from zone to lruvec.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
