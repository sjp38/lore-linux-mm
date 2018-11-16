Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA9086B082B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 02:05:12 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id n32-v6so11195923edc.17
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 23:05:12 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y102-v6si5123530ede.115.2018.11.15.23.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 23:05:11 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAG74Cpw114231
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 02:05:09 -0500
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nsr0etr5t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 02:05:09 -0500
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 16 Nov 2018 07:05:09 -0000
Date: Thu, 15 Nov 2018 23:05:00 -0800
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
Subject: Re: [PATCH tip/core/rcu 6/7] mm: Replace spin_is_locked() with
 lockdep
Reply-To: paulmck@linux.ibm.com
References: <20181111200421.GA10551@linux.ibm.com>
 <20181111200443.10772-6-paulmck@linux.ibm.com>
 <20181115184917.6goqg67hpojfhk42@linux-r8p5>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115184917.6goqg67hpojfhk42@linux-r8p5>
Message-Id: <20181116070500.GV4170@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, joel@joelfernandes.org, Lance Roy <ldr709@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Yang Shi <yang.shi@linux.alibaba.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org

On Thu, Nov 15, 2018 at 10:49:17AM -0800, Davidlohr Bueso wrote:
> On Sun, 11 Nov 2018, Paul E. McKenney wrote:
> 
> >From: Lance Roy <ldr709@gmail.com>
> >
> >lockdep_assert_held() is better suited to checking locking requirements,
> >since it only checks if the current thread holds the lock regardless of
> >whether someone else does. This is also a step towards possibly removing
> >spin_is_locked().
> 
> So fyi I'm not crazy about these kind of patches simply because lockdep
> is a lot less used out of anything that's not a lab, and we can be missing
> potential offenders. There's obviously nothing wrong about what you describe
> above perse, just my two cents.

Fair point!

One countervailing advantage of lockdep is that it is not subject to the
false negatives that can happen if someone else happens to be currently
holding the lock.  But what would you suggest instead?

							Thanx, Paul
