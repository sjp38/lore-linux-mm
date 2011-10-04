Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E73CF900117
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 21:19:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DA2063EE0B6
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:19:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD27645DEB7
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:19:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FDDE45DEB3
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:19:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B4851DB8043
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:19:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E8161DB803E
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:19:32 +0900 (JST)
Date: Tue, 4 Oct 2011 10:18:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 5/8] per-netns ipv4 sysctl_tcp_mem
Message-Id: <20111004101840.442e3c4a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317637123-18306-6-git-send-email-glommer@parallels.com>
References: <1317637123-18306-1-git-send-email-glommer@parallels.com>
	<1317637123-18306-6-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com

On Mon,  3 Oct 2011 14:18:40 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch allows each namespace to independently set up
> its levels for tcp memory pressure thresholds. This patch
> alone does not buy much: we need to make this values
> per group of process somehow. This is achieved in the
> patches that follows in this patchset.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
