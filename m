Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9BB6B034D
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 12:29:15 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q2so550451pgf.22
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 09:29:15 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l61-v6si1383713plb.219.2018.02.07.09.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 09:29:14 -0800 (PST)
Date: Wed, 7 Feb 2018 12:29:10 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207122910.1a91a48e@gandalf.local.home>
In-Reply-To: <20180207171936.GA12446@bombadil.infradead.org>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
	<20180207021703.GC3617@linux.vnet.ibm.com>
	<20180207042334.GA16175@bombadil.infradead.org>
	<alpine.DEB.2.20.1802071040570.22131@nuc-kabylake>
	<20180207120949.62fa815f@gandalf.local.home>
	<20180207171936.GA12446@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Wed, 7 Feb 2018 09:19:36 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> > Please no, I hate subtle internal decisions like this. It makes
> > debugging much more difficult, when allocating dynamic sized variables.
> > When something works at one size but not the other.  
> 
> You know we already have kvmalloc()?

Yes, and the name suggests exactly what it does. It has both "k" and
"v" which tells me that if I use it it could be one or the other.

But a generic "malloc" or "free" that does things differently depending
on the size is a different story.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
