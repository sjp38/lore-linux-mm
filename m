Received: by wa-out-1112.google.com with SMTP id m28so117666wag.8
        for <linux-mm@kvack.org>; Wed, 20 Aug 2008 07:49:06 -0700 (PDT)
Message-ID: <2f11576a0808200749x956cc3fsef5d0eeace243410@mail.gmail.com>
Date: Wed, 20 Aug 2008 23:49:06 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
In-Reply-To: <48AC25E7.4090005@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <48AC25E7.4090005@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi

Thank you very quick responce.

>> Thank you for explain your quicklist plan at OLS.
>>
>> So, I made summary to issue of quicklist.
>> if you have a bit time, Could you please read this mail and patches?
>> And, if possible, Could you please tell me your feeling?
>
> I believe what I said at the OLS was that quicklists are fundamentally crappy
> and should be replaced by something that works (Guess that is what you meant
> by "plan"?). Quicklists were generalized from the IA64 arch code.

Unfortunately, Multiple ia64 customer of my campany are suffered by
Quicklist, now.
because Quicklist works well for HPC likes application, but business
server's application has very different behavior.
IOW, Quicklist works well on best case, but it doesn't concern to worst case.

So, if possible, I'd like to make short term solution.
I believe nobody oppose quicklist reducing. it is defenitly too fat.

> Good fixup but I would think that some more radical rework is needed.
> Maybe some of this needs to vanish into the TLB handling logic?

What do you think wrong TLB handing?
pure performance issue?

> Then I have thought for awhile that the main reason that quicklists exist are
> the performance problems in the page allocator. If you can make the single
> page alloc / free pass competitive in performance with quicklists then we
> could get rid of all uses.

Agreed.
Do you have any page allocator enhancement plan?
Can I help it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
