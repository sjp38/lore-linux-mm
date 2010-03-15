Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A488D6B009C
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 10:20:19 -0400 (EDT)
Date: Mon, 15 Mar 2010 15:20:10 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mm: fix typo in refill_stock() comment
In-Reply-To: <20100311044526.GB17643@balbir.in.ibm.com>
Message-ID: <alpine.LNX.2.00.1003151519530.18642@pobox.suse.cz>
References: <1268255117-3280-1-git-send-email-gthelen@google.com> <20100311093226.8f361e38.nishimura@mxp.nes.nec.co.jp> <20100311044526.GB17643@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010, Balbir Singh wrote:

> > > Change refill_stock() comment: s/consumt_stock()/consume_stock()/
> > > 
> > > Signed-off-by: Greg Thelen <gthelen@google.com>
> > Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> >
> 
> Thanks for catching and fixing this.

I have picked that up into my queue.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
