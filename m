Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADE96B011F
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 16:59:19 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id x10so118377pdj.26
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 13:59:18 -0800 (PST)
Received: from psmtp.com ([74.125.245.176])
        by mx.google.com with SMTP id ar5si209434pbd.32.2013.11.06.13.59.16
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 13:59:17 -0800 (PST)
Received: by mail-qa0-f41.google.com with SMTP id k4so2745539qaq.0
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 13:59:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <527AB7CA.4020502@zytor.com>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	<1383773816.11046.352.camel@schen9-DESK>
	<527AB7CA.4020502@zytor.com>
Date: Wed, 6 Nov 2013 13:59:14 -0800
Message-ID: <CANN689FY67Nu0irKyPxsEPK3NzbpgzKQyW5wLkESfPib9_-zHw@mail.gmail.com>
Subject: Re: [PATCH v3 0/4] MCS Lock: MCS lock code cleanup and optimizations
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, Nov 6, 2013 at 1:42 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> Perhaps I'm missing something here, but what is MCS lock and what is the
> value?

Its a kind of queued lock where each waiter spins on a a separate
memory word, instead of having them all spin on the lock's memory
word. This helps with scalability when many waiters queue on the same
lock.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
