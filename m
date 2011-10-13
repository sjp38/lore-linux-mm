Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BA0A76B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 01:58:27 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C000A3EE0BD
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:58:23 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3CD245DF48
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:58:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B7BDF45DF41
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:58:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A37C21DB803F
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:58:19 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 684D31DB802F
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:58:19 +0900 (JST)
Date: Thu, 13 Oct 2011 14:56:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 4/8] per-cgroup tcp buffers control
Message-Id: <20111013145652.82575b31.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1318242268-2234-5-git-send-email-glommer@parallels.com>
References: <1318242268-2234-1-git-send-email-glommer@parallels.com>
	<1318242268-2234-5-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

On Mon, 10 Oct 2011 14:24:24 +0400
Glauber Costa <glommer@parallels.com> wrote:

> With all the infrastructure in place, this patch implements
> per-cgroup control for tcp memory pressure handling.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Eric W. Biederman <ebiederm@xmission.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
