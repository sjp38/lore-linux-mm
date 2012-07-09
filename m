Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 59A646B0062
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 22:52:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E2B033EE0B5
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:52:52 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA58B45DE5C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:52:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B06D445DE55
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:52:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EC291DB8047
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:52:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53CD01DB8053
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:52:52 +0900 (JST)
Message-ID: <4FFA4703.7010109@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 11:50:43 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 06/11] mm: memcg: move swapin charge functions above callsites
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-7-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:44), Johannes Weiner wrote:
> Charging cache pages may require swapin in the shmem case.  Save the
> forward declaration and just move the swapin functions above the cache
> charging functions.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
