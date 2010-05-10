Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 73DEC6B024D
	for <linux-mm@kvack.org>; Mon, 10 May 2010 02:30:51 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4A6Ulox028432
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 May 2010 15:30:47 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C25E45DE4E
	for <linux-mm@kvack.org>; Mon, 10 May 2010 15:30:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EE8D645DE4D
	for <linux-mm@kvack.org>; Mon, 10 May 2010 15:30:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF8841DB8038
	for <linux-mm@kvack.org>; Mon, 10 May 2010 15:30:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BDCF1DB803F
	for <linux-mm@kvack.org>; Mon, 10 May 2010 15:30:46 +0900 (JST)
Date: Mon, 10 May 2010 15:26:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] cgroups: make cftype.unregister_event()
 void-returning
Message-Id: <20100510152644.3ff6e0a5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100510150815.3d2f7647.kamezawa.hiroyu@jp.fujitsu.com>
References: <1273363822-7796-1-git-send-email-kirill@shutemov.name>
	<20100510150815.3d2f7647.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Phil Carmody <ext-phil.2.carmody@nokia.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 May 2010 15:08:15 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Sun,  9 May 2010 03:10:22 +0300
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > Since we unable to handle error returned by cftype.unregister_event()
> > properly, let's make the callback void-returning.
> > 
> > mem_cgroup_unregister_event() has been rewritten to be "never fail"
> > function. On mem_cgroup_usage_register_event() we save old buffer
> > for thresholds array and reuse it in mem_cgroup_usage_unregister_event()
> > to avoid allocation.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> 
> Hmm, just reusing buffer isn't enough ?
> as
> 	tmp = memory->thresholds;
> 	reduce entries on tmp
> And what happens when
> 
> 	register
> 	register
> 	register	
> 	unregister  (use preallocated buffer)
> 	unregister  ????
> 	unregister
> 
Ah, sorry my eyes were wrong.

The fix seems to work. 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
