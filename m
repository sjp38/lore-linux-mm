Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B07460021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 21:35:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS2ZCYh003443
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 11:35:12 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A4F345DE56
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:35:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 03C0545DE51
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:35:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DC23C1DB8042
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:35:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 613761DB803A
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:35:11 +0900 (JST)
Date: Mon, 28 Dec 2009 11:31:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 1/4] cgroup: implement eventfd-based generic API for
 notifications
Message-Id: <20091228113154.e2c2566e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <3f29ccc3c93e2defd70fc1c4ca8c133908b70b0b.1261858972.git.kirill@shutemov.name>
References: <cover.1261858972.git.kirill@shutemov.name>
	<3f29ccc3c93e2defd70fc1c4ca8c133908b70b0b.1261858972.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Dec 2009 04:08:59 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> This patch introduces write-only file "cgroup.event_control" in every
> cgroup.
> 
> To register new notification handler you need:
> - create an eventfd;
> - open a control file to be monitored. Callbacks register_event() and
>   unregister_event() must be defined for the control file;
> - write "<event_fd> <control_fd> <args>" to cgroup.event_control.
>   Interpretation of args is defined by control file implementation;
> 
> eventfd will be woken up by control file implementation or when the
> cgroup is removed.
> 
> To unregister notification handler just close eventfd.
> 
> If you need notification functionality for a control file you have to
> implement callbacks register_event() and unregister_event() in the
> struct cftype.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
