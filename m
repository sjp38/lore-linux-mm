Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 10EE86B0036
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 21:32:44 -0400 (EDT)
Message-ID: <51CB9631.1030508@intel.com>
Date: Thu, 27 Jun 2013 09:32:33 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/5] rwsem: check the lock before cpmxchg in down_write_trylock
References: <cover.1372282738.git.tim.c.chen@linux.intel.com> <1372285674.22432.141.camel@schen9-DESK>
In-Reply-To: <1372285674.22432.141.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


The following line should be added head of commit log on patches 1~4. :)

From: Alex Shi <alex.shi@intel.com>


> Cmpxchg will cause the cacheline bouning when do the value checking,
> that cause scalability issue in a large machine (like a 80 core box).
> 
> So a lock pre-read can relief this contention.
> 
> Signed-off-by: Alex Shi <alex.shi@intel.com>


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
