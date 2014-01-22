Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5BB6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 16:19:38 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id r7so69287bkg.19
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:19:37 -0800 (PST)
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
        by mx.google.com with ESMTPS id dh4si8027805bkc.334.2014.01.22.13.19.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 13:19:37 -0800 (PST)
Received: by mail-bk0-f46.google.com with SMTP id r7so69284bkg.19
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:19:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <26254409.YmoYKsf1IQ@radagast>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
	<1390267479.3138.40.camel@schen9-DESK>
	<26254409.YmoYKsf1IQ@radagast>
Date: Wed, 22 Jan 2014 21:19:36 +0000
Message-ID: <CAAG0J98eyP8Jy9P1iQ0eO6UCJ6fdqD7V-f0TaoT-LegyYGTEgA@mail.gmail.com>
Subject: Re: [PATCH v8 6/6] MCS Lock: Allow architecture specific asm files to
 be used for contended case
From: James Hogan <james.hogan@imgtec.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On 22 January 2014 21:15, James Hogan <james.hogan@imgtec.com> wrote:
> Hi,
>
> On Monday 20 January 2014 17:24:39 Tim Chen wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> This patch allows each architecture to add its specific assembly optimized
>> arch_mcs_spin_lock_contended and arch_mcs_spinlock_uncontended for
>> MCS lock and unlock functions.
>>
>> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
>
> Where possible can you try and maintain the sort order in the Kbuild files?


Sorry for the noise, I see this is already taken care of. These emails
got filtered funny without any of the replies so I didn't see straight
away.

Cheers
James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
