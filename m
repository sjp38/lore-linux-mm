Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E48D6B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:29:13 -0500 (EST)
Date: Mon, 15 Feb 2010 22:28:45 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch -mm 6/9 v2] oom: deprecate oom_adj tunable
Message-ID: <20100215222845.0b0f2781@lxorguk.ukuu.org.uk>
In-Reply-To: <alpine.DEB.2.00.1002151418560.26927@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151418560.26927@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010 14:20:16 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> /proc/pid/oom_adj is now deprecated so that that it may eventually be
> removed.  The target date for removal is December 2011.

There are systems that rely on this feature. It's ABI, its sacred. We are
committed to it and it has users. That doesn't really detract from the
good/bad of the rest of the proposal, it's just one step we can't quite
make.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
