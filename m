Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 264776B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 14:12:28 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f3so13008318pgv.21
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:12:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h10si10429891pgq.169.2017.12.19.11.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 11:12:26 -0800 (PST)
Date: Tue, 19 Dec 2017 11:12:22 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Message-ID: <20171219191222.GA6515@bombadil.infradead.org>
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rao.shoaib@oracle.com
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

On Tue, Dec 19, 2017 at 09:52:27AM -0800, rao.shoaib@oracle.com wrote:
> This patch updates kfree_rcu to use new bulk memory free functions as they
> are more efficient. It also moves kfree_call_rcu() out of rcu related code to
> mm/slab_common.c
> 
> Signed-off-by: Rao Shoaib <rao.shoaib@oracle.com>
> ---
>  include/linux/mm.h |   5 ++
>  kernel/rcu/tree.c  |  14 ----
>  kernel/sysctl.c    |  40 +++++++++++
>  mm/slab.h          |  23 +++++++
>  mm/slab_common.c   | 198 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  5 files changed, 264 insertions(+), 16 deletions(-)

You've added an awful lot of code.  Do you have any performance measurements
that shows this to be a win?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
