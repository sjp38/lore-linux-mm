Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E8BE86B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 20:53:43 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a5so12087016pgu.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 17:53:43 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q7si12217734plk.225.2017.12.19.17.53.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 17:53:42 -0800 (PST)
Date: Tue, 19 Dec 2017 17:53:36 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Message-ID: <20171220015336.GA7748@bombadil.infradead.org>
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <20171219214158.353032f0@redhat.com>
 <20171219221206.GA22696@bombadil.infradead.org>
 <20171220002051.GJ7829@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171220002051.GJ7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, rao.shoaib@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 19, 2017 at 04:20:51PM -0800, Paul E. McKenney wrote:
> If we are going to make this sort of change, we should do so in a way
> that allows the slab code to actually do the optimizations that might
> make this sort of thing worthwhile.  After all, if the main goal was small
> code size, the best approach is to drop kfree_bulk() and get on with life
> in the usual fashion.
> 
> I would prefer to believe that something like kfree_bulk() can help,
> and if that is the case, we should give it a chance to do things like
> group kfree_rcu() requests by destination slab and soforth, allowing
> batching optimizations that might provide more significant increases
> in performance.  Furthermore, having this in slab opens the door to
> slab taking emergency action when memory is low.

kfree_bulk does sort by destination slab; look at build_detached_freelist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
