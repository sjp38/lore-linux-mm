Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A58E6B0355
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 12:54:26 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id i135so2425228ita.9
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 09:54:26 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id b186si129296ith.72.2018.02.07.09.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 09:54:25 -0800 (PST)
Date: Wed, 7 Feb 2018 11:54:22 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
In-Reply-To: <20180207122910.1a91a48e@gandalf.local.home>
Message-ID: <alpine.DEB.2.20.1802071152580.22710@nuc-kabylake>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain> <20180207021703.GC3617@linux.vnet.ibm.com> <20180207042334.GA16175@bombadil.infradead.org> <alpine.DEB.2.20.1802071040570.22131@nuc-kabylake> <20180207120949.62fa815f@gandalf.local.home>
 <20180207171936.GA12446@bombadil.infradead.org> <20180207122910.1a91a48e@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Matthew Wilcox <willy@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Wed, 7 Feb 2018, Steven Rostedt wrote:

> But a generic "malloc" or "free" that does things differently depending
> on the size is a different story.

They would not be used for cases with special requirements but for the
throwaway allows where noone cares about these details. Its just a
convenience for the developers that do not need to be bothered with too
much detail because they are not dealing with codepaths that have special
requirements.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
