Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 788DE6B00E6
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 10:32:11 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md4so9171444pbc.30
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 07:32:11 -0800 (PST)
Received: from psmtp.com ([74.125.245.181])
        by mx.google.com with SMTP id fn9si3170562pab.78.2013.11.06.07.32.08
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 07:32:09 -0800 (PST)
Message-ID: <527A60E3.3000106@hp.com>
Date: Wed, 06 Nov 2013 10:31:47 -0500
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/4] MCS Lock: Make mcs_spinlock.h includable in other
 files
References: <cover.1383670202.git.tim.c.chen@linux.intel.com>  <1383673359.11046.280.camel@schen9-DESK>  <20131105185717.GZ16117@laptop.programming.kicks-ass.net> <1383679842.11046.298.camel@schen9-DESK>
In-Reply-To: <1383679842.11046.298.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>

On 11/05/2013 02:30 PM, Tim Chen wrote:
> On Tue, 2013-11-05 at 19:57 +0100, Peter Zijlstra wrote:
>> On Tue, Nov 05, 2013 at 09:42:39AM -0800, Tim Chen wrote:
>>> + * The _raw_mcs_spin_lock() function should not be called directly. Instead,
>>> + * users should call mcs_spin_lock().
>>>    */
>>> -static noinline
>>> -void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>>> +static inline
>>> +void _raw_mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>>>   {
>>>   	struct mcs_spinlock *prev;
>>>
>> So why keep it in the header at all?
> I also made the suggestion originally of keeping both lock and unlock in
> mcs_spinlock.c.  Wonder if Waiman decides to keep them in header
> because in-lining the unlock function makes execution a bit faster?
>
> Tim
>

I was following the example of the spinlock code where the lock function 
is not inlined, but the unlock function is. I have no objection to make 
them both as non-inlined functions, if you think that is the right move.

Regards,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
