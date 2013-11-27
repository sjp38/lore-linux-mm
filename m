Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF1906B0031
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 22:00:39 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so3094585yho.24
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 19:00:39 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id z5si26071283yhd.299.2013.11.26.19.00.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Nov 2013 19:00:38 -0800 (PST)
Message-Id: <201311270259.rAR2xBI6003167@mail.zytor.com>
In-Reply-To: <20131127012719.GJ4137@linux.vnet.ibm.com>
References: <20131121215249.GZ16796@laptop.programming.kicks-ass.net> <20131121221859.GH4138@linux.vnet.ibm.com> <20131122155835.GR3866@twins.programming.kicks-ass.net> <20131122182632.GW4138@linux.vnet.ibm.com> <20131122185107.GJ4971@laptop.programming.kicks-ass.net> <20131125173540.GK3694@twins.programming.kicks-ass.net> <20131125180250.GR4138@linux.vnet.ibm.com> <5293E37F.5020908@zytor.com> <20131126031626.GE4138@linux.vnet.ibm.com> <529540FE.3070504@zytor.com> <20131127012719.GJ4137@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 26 Nov 2013 18:59:01 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Figo.zhang@zytor.com

<figo1802@gmail.com>
Message-ID: <589ca54b-4171-4164-b9ba-dc3a5bad6376@email.android.com>

Yes, if you have concrete scenarios we can discuss them.

"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
>On Tue, Nov 26, 2013 at 04:46:54PM -0800, H. Peter Anvin wrote:
>> On 11/25/2013 07:16 PM, Paul E. McKenney wrote:
>> > 
>> > My biggest question is the definition of "Memory ordering obeys
>causality
>> > (memory ordering respects transitive visibility)" in Section 3.2.2
>of
>> > the "IntelA(R) 64 and IA-32 Architectures Developer's Manual: Vol. 3A"
>> > dated March 2013 from:
>> > 
>> >
>http://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-3a-part-1-manual.html
>> > 
>> > I am guessing that is orders loads as well as stores, so that a
>load
>> > is said to be "visible" to some other CPU once that CPU no longer
>has
>> > the opportunity to affect the return value from the load.  Is that
>a
>> > reasonable interpretation?
>> 
>> The best pointer I can give is the example in section 8.2.3.6 of the
>> current SDM (version 048, dated September 2013).  It is a bit more
>> complex than what you have described above.
>
>OK, I did see that example.  It is similar to the one we are chasing
>in this thread, but there are some important differences.  But you
>did mention that that other example operated as expected on x86, so
>we are good for the moment.  I was hoping to gain more general
>understanding, but I would guess that there will be other examples
>to help towards that goal.  ;-)
>
>> > More generally, is the model put forward by Sewell et al. in
>"x86-TSO:
>> > A Rigorous and Usable Programmer's Model for x86 Multiprocessors"
>> > accurate?  This is on pages 4 and 5 here:
>> > 
>> > 	http://www.cl.cam.ac.uk/~pes20/weakmemory/cacm.pdf
>> 
>> I think for Intel to give that one a formal stamp of approval would
>take
>> some serious analysis.
>
>I bet!!!
>
>Hey, I had to ask!  ;-)
>
>							Thanx, Paul

-- 
Sent from my mobile phone.  Please pardon brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
