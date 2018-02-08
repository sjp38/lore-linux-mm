Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86CF46B000C
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 23:10:35 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id z64so2713060qka.23
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 20:10:35 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y187si502684qkc.309.2018.02.07.20.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 20:10:34 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1849S1F096797
	for <linux-mm@kvack.org>; Wed, 7 Feb 2018 23:10:34 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g09d93vxh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Feb 2018 23:10:34 -0500
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 7 Feb 2018 23:10:33 -0500
Date: Wed, 7 Feb 2018 20:10:39 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Reply-To: paulmck@linux.vnet.ibm.com
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <20180207021703.GC3617@linux.vnet.ibm.com>
 <20180207042334.GA16175@bombadil.infradead.org>
 <20180207050200.GH3617@linux.vnet.ibm.com>
 <db9bda80-7506-ae25-2c0a-45eaa08963d9@virtuozzo.com>
 <20180207083104.GK3617@linux.vnet.ibm.com>
 <20180207085700.393f90d0@gandalf.local.home>
 <20180207174513.5cc9b503@redhat.com>
 <20180207181055.GB12446@bombadil.infradead.org>
 <20180207132619.6595e4a9@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207132619.6595e4a9@gandalf.local.home>
Message-Id: <20180208041039.GR3617@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rao.shoaib@oracle.com

On Wed, Feb 07, 2018 at 01:26:19PM -0500, Steven Rostedt wrote:
> On Wed, 7 Feb 2018 10:10:55 -0800
> Matthew Wilcox <willy@infradead.org> wrote:
> 
> > > For the record, I fully agree with Steve here. 
> 
> Thanks, but...
> 
> > > 
> > > And being a performance "fanatic" I don't like to have the extra branch
> > > (and compares) in the free code path... but it's a MM-decision (and
> > > sometimes you should not listen to "fanatics" ;-))  
> > 
> > While free_rcu() is not withut its performance requirements, I think it's
> > currently dominated by cache misses and not by branches.  By the time RCU
> > gets to run callbacks, memory is certainly L1/L2 cache-cold and probably
> > L3 cache-cold.  Also calling the callback functions is utterly impossible
> > for the branch predictor.
> 
> I agree with Matthew.
> 
> This is far from any fast path. A few extra branches isn't going to
> hurt anything here as it's mostly just garbage collection. With or
> without the Spectre fixes.

What Steve said!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
