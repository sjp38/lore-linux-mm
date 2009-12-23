Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 00AA7620002
	for <linux-mm@kvack.org>; Tue, 22 Dec 2009 19:26:47 -0500 (EST)
Date: Tue, 22 Dec 2009 16:26:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mmotm 4/8] memcg: move charges of anonymous page
Message-Id: <20091222162633.aaec7c3c.akpm@linux-foundation.org>
In-Reply-To: <20091221143503.dab0a48a.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143503.dab0a48a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 14:35:03 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> +/* "mc" and its members are protected by cgroup_mutex */
> +struct move_charge_struct {
> +	struct mem_cgroup *from;
> +	struct mem_cgroup *to;
> +	unsigned long precharge;
> +};
> +static struct move_charge_struct mc;

This is neater:

/* "mc" and its members are protected by cgroup_mutex */
static struct move_charge_struct {
	struct mem_cgroup *from;
	struct mem_cgroup *to;
	unsigned long precharge;
} mc;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
