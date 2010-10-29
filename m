Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5676B0144
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:20:32 -0400 (EDT)
Date: Fri, 29 Oct 2010 13:19:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 09/11] memcg: CPU hotplug lockdep warning fix
Message-Id: <20101029131957.e0ea4013.akpm@linux-foundation.org>
In-Reply-To: <1288336154-23256-10-git-send-email-gthelen@google.com>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-10-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 00:09:12 -0700
Greg Thelen <gthelen@google.com> wrote:

> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> memcg has lockdep warnings (sleep inside rcu lock)
> >
> ...
>
> Acked-by: Greg Thelen <gthelen@google.com>

You were on the patch delivery path, so this should be Signed-off-by:. 
I made that change to my copy.

> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
