Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1F96B054E
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 13:49:30 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so1301757ede.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 10:49:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u2-v6si2817765ejo.76.2018.11.15.10.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 10:49:28 -0800 (PST)
Date: Thu, 15 Nov 2018 10:49:17 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH tip/core/rcu 6/7] mm: Replace spin_is_locked() with
 lockdep
Message-ID: <20181115184917.6goqg67hpojfhk42@linux-r8p5>
References: <20181111200421.GA10551@linux.ibm.com>
 <20181111200443.10772-6-paulmck@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181111200443.10772-6-paulmck@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, joel@joelfernandes.org, Lance Roy <ldr709@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Yang Shi <yang.shi@linux.alibaba.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org

On Sun, 11 Nov 2018, Paul E. McKenney wrote:

>From: Lance Roy <ldr709@gmail.com>
>
>lockdep_assert_held() is better suited to checking locking requirements,
>since it only checks if the current thread holds the lock regardless of
>whether someone else does. This is also a step towards possibly removing
>spin_is_locked().

So fyi I'm not crazy about these kind of patches simply because lockdep
is a lot less used out of anything that's not a lab, and we can be missing
potential offenders. There's obviously nothing wrong about what you describe
above perse, just my two cents.

Thansk,
Davidlohr
