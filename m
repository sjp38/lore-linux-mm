Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 125F06B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:34:34 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBH0YVKP017631
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Dec 2009 09:34:32 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9846E45DE56
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 09:34:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 62E6C45DE4E
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 09:34:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 362A91DB8043
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 09:34:31 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5DD61DB803E
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 09:34:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: introduce dump_page() and print symbolic flag names
In-Reply-To: <20091216152856.GB2804@hack>
References: <20091216122640.GA13817@localhost> <20091216152856.GB2804@hack>
Message-Id: <20091217092720.7ACC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 17 Dec 2009 09:34:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Americo Wang <xiyou.wangcong@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Alex Chiang <achiang@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Dec 16, 2009 at 08:26:40PM +0800, Wu Fengguang wrote:
> >- introduce dump_page() to print the page info for debugging some error condition.
> 
> Since it is for debugging, shouldn't it be surrounded by
> CONFIG_DEBUG_VM too? :-/

No.
typically, wrong driver makes bad_page() calling and MM developer suggested
how to fix in lkml. then, MM developer hope it is enabled on end user's
machine.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
