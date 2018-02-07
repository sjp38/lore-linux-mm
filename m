Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE8EF6B0339
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 11:47:06 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id d62so1633606iof.8
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 08:47:06 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id r142si199309itr.18.2018.02.07.08.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 08:47:06 -0800 (PST)
Date: Wed, 7 Feb 2018 10:47:02 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
In-Reply-To: <20180207042334.GA16175@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802071040570.22131@nuc-kabylake>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain> <20180207021703.GC3617@linux.vnet.ibm.com> <20180207042334.GA16175@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Tue, 6 Feb 2018, Matthew Wilcox wrote:

> Personally, I would like us to rename kvfree() to just free(), and have
> malloc(x) be an alias to kvmalloc(x, GFP_KERNEL), but I haven't won that
> fight yet.

Maybe lets implement malloc(), free() and realloc() in the kernel to be
consistent with user space use as possible? Only use the others
allocation variants for special cases.

So malloc would check allocation sizes and if < 2* PAGE_SIZE use kmalloc()
otherwise vmalloc().

free() would free anything you give it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
