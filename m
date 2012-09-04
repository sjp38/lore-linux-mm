Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 713096B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:06:17 -0400 (EDT)
Date: Tue, 4 Sep 2012 15:06:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V1 0/2] Enable clients to schedule in mmu_notifier
 methods
Message-Id: <20120904150615.f6c1a618.akpm@linux-foundation.org>
In-Reply-To: <1346748081-1652-1-git-send-email-haggaie@mellanox.com>
References: <1346748081-1652-1-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Shachar Raindel <raindel@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>

On Tue,  4 Sep 2012 11:41:19 +0300
Haggai Eran <haggaie@mellanox.com> wrote:

> > This patchset is a preliminary step towards on-demand paging design to be
> > added to the Infiniband stack.

The above sentence is the most important part of the patchset.  Because
it answers the question "ytf is Haggai sending this stuff at me".

I'm unsure if the patchset adds runtime overhead but it does add
maintenance overhead (perhaps we can reduce this - see later emails). 
So we need to take a close look at what we're getting in return for
that overhead, please.

Exactly why do we want on-demand paging for Infiniband?  Why should
anyone care?  What problems are users currently experiencing?  How many
users and how serious are the problems and what if any workarounds are
available?

Is there any prospect that any other subsystems will utilise these
infrastructural changes?  If so, which and how, etc?



IOW, sell this code to us!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
