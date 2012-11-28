Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 74CB86B0068
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 09:21:17 -0500 (EST)
Message-ID: <50B61DD6.5020005@intel.com>
Date: Wed, 28 Nov 2012 22:21:10 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: numa/core regressions fixed - more testers wanted
References: <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com> <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com> <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com> <20121120071704.GA14199@gmail.com> <20121120152933.GA17996@gmail.com> <20121120175647.GA23532@gmail.com> <CAGjg+kHKaQLcrnEftB+2mjeCjGUBiisSOpNCe+_9-4LDho9LpA@mail.gmail.com> <20121122012122.GA7938@gmail.com> <20121123133138.GA28058@gmail.com> <CAGjg+kE8=cp=NyHrviyRWAZ=id6sZM1Gtb0N1_+SZ2TuBHE5cw@mail.gmail.com>
In-Reply-To: <CAGjg+kE8=cp=NyHrviyRWAZ=id6sZM1Gtb0N1_+SZ2TuBHE5cw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <lkml.alex@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

> 
>>
>> Could you please check tip:master with -v17:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master
>>

Tested this version on our SNB EP 2 sockets box, 8 cores * HT with
specjbb2005 on jrockit.
With single JVM setting it has 40% performance increase compare to
3.7-rc6. impressive!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
