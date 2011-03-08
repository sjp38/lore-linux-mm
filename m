Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5EA8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 01:08:08 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EE1BA3EE0BD
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:08:03 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D62D145DE59
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:08:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BDA8745DE58
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:08:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AC62D1DB804A
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:08:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 75E801DB803A
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:08:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V2] page-types.c: auto debugfs mount for hwpoison operation
In-Reply-To: <4D75B815.2080603@linux.intel.com>
References: <20110307113937.GB5080@localhost> <4D75B815.2080603@linux.intel.com>
Message-Id: <20110308150824.7EC2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  8 Mar 2011 15:08:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gong <gong.chen@linux.intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Clark Williams <williams@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>

> page-types.c doesn't supply a way to specify the debugfs path and
> the original debugfs path is not usual on most machines. This patch
> supplies a way to auto mount debugfs if needed.
> 
> This patch is heavily inspired by tools/perf/utils/debugfs.c
> 
> Signed-off-by: Chen Gong <gong.chen@linux.intel.com>
> ---
>   Documentation/vm/page-types.c |  105 
> +++++++++++++++++++++++++++++++++++++++--
>   1 files changed, 101 insertions(+), 4 deletions(-)


Cute!
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
