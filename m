Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44DC26B0349
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 12:19:59 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id h33-v6so261417plh.19
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 09:19:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l193si1183791pge.274.2018.02.07.09.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Feb 2018 09:19:58 -0800 (PST)
Date: Wed, 7 Feb 2018 09:19:36 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207171936.GA12446@bombadil.infradead.org>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <20180207021703.GC3617@linux.vnet.ibm.com>
 <20180207042334.GA16175@bombadil.infradead.org>
 <alpine.DEB.2.20.1802071040570.22131@nuc-kabylake>
 <20180207120949.62fa815f@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207120949.62fa815f@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Christopher Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Wed, Feb 07, 2018 at 12:09:49PM -0500, Steven Rostedt wrote:
> > Maybe lets implement malloc(), free() and realloc() in the kernel to be
> > consistent with user space use as possible? Only use the others
> > allocation variants for special cases.
> 
> They would need to drop the GFP part and default to GFP_KERNEL.

Yes, exactly.

> > So malloc would check allocation sizes and if < 2* PAGE_SIZE use kmalloc()
> > otherwise vmalloc().
> 
> Please no, I hate subtle internal decisions like this. It makes
> debugging much more difficult, when allocating dynamic sized variables.
> When something works at one size but not the other.

You know we already have kvmalloc()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
