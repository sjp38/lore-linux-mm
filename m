Received: by ug-out-1314.google.com with SMTP id c2so43803ugf
        for <linux-mm@kvack.org>; Tue, 10 Jul 2007 22:47:04 -0700 (PDT)
Message-ID: <2c0942db0707102247n3b6e5933i9803a2161d6c00b1@mail.gmail.com>
Date: Tue, 10 Jul 2007 22:47:04 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <4694683B.3060705@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <b21f8390707101802o2d546477n2a18c1c3547c3d7a@mail.gmail.com>
	 <20070710181419.6d1b2f7e.akpm@linux-foundation.org>
	 <b21f8390707101954s3ae69db8vc30287277941cb1f@mail.gmail.com>
	 <4694683B.3060705@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matthew Hawkins <darthmdh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Con Kolivas <kernel@kolivas.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/10/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Matthew Hawkins wrote:
> > On 7/11/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> > Anyhow with swap prefetch, applications that may have been sitting
> > there idle for a while become responsive in the single-digit seconds
> > rather than double-digit or worse.  The same goes for a morning wakeup
> > (ie after nightly cron jobs throw things out)
>
> OK that's a good data point. It would be really good to be able to
> do an analysis on your overnight IO patterns and the corresponding
> memory reclaim behaviour and see why things are getting evicted.

Eviction can happen for multiple reasons, as I'm sure you're painfully
aware. It can happen because of poor balancing choices, or it can
happen because the system is just short of RAM for the workload. As
for the former, you're absolutely right, it would be good to know
where those come from and see if they can be addressed.

However, it's the latter that swap prefetch can help and no amount of
fiddling with the aging code can address.

As an honest question, what's it going to take here? If I were to
write something that watched the task stats at process exit (cool
feature, that), and recorded the IO wait time or some such, and showed
it was lower with a kernel with the prefetch, would *that* get us some
forward motion on this?

I mean, from my point of view, it's a simple mental proof to show that
if you're out of RAM for your working set, things that you'll
eventually need again will get kicked out, and prefetch will bring
those back in before normal access patterns would fault them back in
under today's behavior. That seems like an obvious win. Where's the
corresponding obvious loss that makes this a questionable addition to
the kernel?

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
