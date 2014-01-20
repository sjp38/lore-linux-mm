Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f181.google.com (mail-gg0-f181.google.com [209.85.161.181])
	by kanga.kvack.org (Postfix) with ESMTP id A83876B0036
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 08:59:17 -0500 (EST)
Received: by mail-gg0-f181.google.com with SMTP id 21so2112924ggh.26
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 05:59:17 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id g5si1329091yhd.162.2014.01.20.05.59.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jan 2014 05:59:16 -0800 (PST)
Date: Mon, 20 Jan 2014 14:58:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 0/6] MCS Lock: MCS lock code cleanup and optimizations
Message-ID: <20140120135847.GG31570@twins.programming.kicks-ass.net>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917284.3138.10.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389917284.3138.10.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Jan 16, 2014 at 04:08:04PM -0800, Tim Chen wrote:
> This is an update of the MCS lock patch series posted in November.

Aside from the smallish gripes I posted about;

Acked-by: Peter Zijlstra <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
