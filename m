Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8EF6B0319
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 09:55:50 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 102so1391104ior.2
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 06:55:50 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id m3si1109774iob.136.2018.02.07.06.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 06:55:49 -0800 (PST)
Date: Wed, 7 Feb 2018 08:55:47 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
In-Reply-To: <20180207021703.GC3617@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1802070854080.21329@nuc-kabylake>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain> <20180207021703.GC3617@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Tue, 6 Feb 2018, Paul E. McKenney wrote:

> So it is OK to kvmalloc() something and pass it to either kfree() or
> kvfree(), and it had better be OK to kvmalloc() something and pass it
> to kvfree().

kvfree() is fine but not kfree().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
