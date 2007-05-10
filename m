Received: by py-out-1112.google.com with SMTP id v53so546566pyh
        for <linux-mm@kvack.org>; Thu, 10 May 2007 05:34:16 -0700 (PDT)
Message-ID: <2c0942db0705100534xd4bc77eq76dd728fedc855b9@mail.gmail.com>
Date: Thu, 10 May 2007 05:34:16 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
In-Reply-To: <4642C416.3000205@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <200705100928.34056.kernel@kolivas.org>
	 <464261B5.6030809@yahoo.com.au>
	 <200705101134.34350.kernel@kolivas.org> <46427BDB.30004@yahoo.com.au>
	 <2c0942db0705092048m38b36e7fo3a7c2c59fe1612b2@mail.gmail.com>
	 <46429801.8030202@yahoo.com.au>
	 <2c0942db0705092252n13a6a79aq39f13fcfae534de2@mail.gmail.com>
	 <4642C416.3000205@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Con Kolivas <kernel@kolivas.org>, Ingo Molnar <mingo@elte.hu>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/10/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > Huh? You already stated one version of it above, namely updatedb. But
>
> So a swapping problem with updatedb should be unusual and we'd like to see
> if we can fix it without resorting to prefetching.
>
> I know the theory behind swap prefetching, and I'm not saying it doesn't
> work, so I'll snip the rest of that.

updatedb is only part of the problem. The other part is that the
kernel has an opportunity to preemptively return some of the evicted
working set to RAM before I ask for it. No fancy use-once algorithm is
going to address that, so your solution is provably incomplete for my
problem.

What's so hard to understand about that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
