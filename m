Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id AC1976B0039
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:56:53 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so3429023yhz.13
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:56:53 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id x27si22306688yhk.61.2013.11.25.15.56.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Nov 2013 15:56:52 -0800 (PST)
Message-ID: <5293E37F.5020908@zytor.com>
Date: Mon, 25 Nov 2013 15:55:43 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
References: <20131121110308.GC10022@twins.programming.kicks-ass.net> <20131121125616.GI3694@twins.programming.kicks-ass.net> <20131121132041.GS4138@linux.vnet.ibm.com> <20131121172558.GA27927@linux.vnet.ibm.com> <20131121215249.GZ16796@laptop.programming.kicks-ass.net> <20131121221859.GH4138@linux.vnet.ibm.com> <20131122155835.GR3866@twins.programming.kicks-ass.net> <20131122182632.GW4138@linux.vnet.ibm.com> <20131122185107.GJ4971@laptop.programming.kicks-ass.net> <20131125173540.GK3694@twins.programming.kicks-ass.net> <20131125180250.GR4138@linux.vnet.ibm.com>
In-Reply-To: <20131125180250.GR4138@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On 11/25/2013 10:02 AM, Paul E. McKenney wrote:
> 
> I still do not believe that it does.  Again, strangely enough.
> 
> We need to ask someone in Intel that understands this all the way down
> to the silicon.  The guy I used to rely on for this no longer works
> at Intel.
> 
> Do you know someone who fits this description, or should I start sending
> cold-call emails to various Intel contacts?
> 

Feel free to poke me if you need any help.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
