Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id E65446B0033
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 11:59:17 -0400 (EDT)
Subject: Re: [PATCH v4 1/5] rwsem: check the lock before cpmxchg in
 down_write_trylock
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <51CB9631.1030508@intel.com>
References: <cover.1372282738.git.tim.c.chen@linux.intel.com>
	 <1372285674.22432.141.camel@schen9-DESK>  <51CB9631.1030508@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 27 Jun 2013 08:59:18 -0700
Message-ID: <1372348758.22432.153.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Thu, 2013-06-27 at 09:32 +0800, Alex Shi wrote:
> The following line should be added head of commit log on patches 1~4. :)
> 
> From: Alex Shi <alex.shi@intel.com>
> 
> 
> > Cmpxchg will cause the cacheline bouning when do the value checking,
> > that cause scalability issue in a large machine (like a 80 core box).
> > 
> > So a lock pre-read can relief this contention.
> > 
> > Signed-off-by: Alex Shi <alex.shi@intel.com>
> 
> 

Okay.  Will add the From line in addition to Signed off line on next
update.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
