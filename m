Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8858D60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 21:33:23 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS2XKPp026030
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 11:33:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A4A845DE52
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:33:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 62E2F45DE4D
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:33:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47F391DB803F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:33:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 029581DB8038
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:33:20 +0900 (JST)
Date: Mon, 28 Dec 2009 11:30:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 2/4] memcg: extract mem_group_usage() from
 mem_cgroup_read()
Message-Id: <20091228113003.196012e1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <59a7f92356bf1508f06d12c501a7aa4feffb1bbc.1261858972.git.kirill@shutemov.name>
References: <cover.1261858972.git.kirill@shutemov.name>
	<3f29ccc3c93e2defd70fc1c4ca8c133908b70b0b.1261858972.git.kirill@shutemov.name>
	<59a7f92356bf1508f06d12c501a7aa4feffb1bbc.1261858972.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Dec 2009 04:09:00 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Helper to get memory or mem+swap usage of the cgroup.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
