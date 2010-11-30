Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 362E66B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:24:12 -0500 (EST)
Date: Tue, 30 Nov 2010 14:23:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] Move zone_reclaim() outside of CONFIG_NUMA
Message-Id: <20101130142338.5e845880.akpm@linux-foundation.org>
In-Reply-To: <20101130101506.17475.34536.stgit@localhost6.localdomain6>
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
	<20101130101506.17475.34536.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 15:45:12 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> This patch moves zone_reclaim and associated helpers
> outside CONFIG_NUMA. This infrastructure is reused
> in the patches for page cache control that follow.
> 

Thereby adding a nice dollop of bloat to everyone's kernel.  I don't
think that is justifiable given that the audience for this feature is
about eight people :(

How's about CONFIG_UNMAPPED_PAGECACHE_CONTROL?

Also this patch instantiates sysctl_min_unmapped_ratio and
sysctl_min_slab_ratio on non-NUMA builds but fails to make those
tunables actually tunable in procfs.  Changes to sysctl.c are
needed.

> Reviewed-by: Christoph Lameter <cl@linux.com>

More careful reviewers, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
