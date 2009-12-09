Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2E67A60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 06:30:38 -0500 (EST)
Date: Wed, 9 Dec 2009 20:30:18 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [BUG?] [PATCH] soft limits and root cgroups
Message-Id: <20091209203018.7a85d304.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <cc557aab0912090137l5f4c923by9b3fbe5241bbf49a@mail.gmail.com>
References: <cc557aab0912071041j5c5731dbj9fd669ef26e6f2ae@mail.gmail.com>
	<cc557aab0912090137l5f4c923by9b3fbe5241bbf49a@mail.gmail.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 2009 11:37:30 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Dec 7, 2009 at 8:41 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > Currently, mem_cgroup_update_tree() on root cgroup calls only on
> > uncharge, not on charge.
> >
> > Is it a bug or not?
> 
> Any comments?
> 
It's not a bug.
Please see my comments and patch ;)

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
