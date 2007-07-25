Date: Tue, 24 Jul 2007 18:35:27 -0700 (PDT)
Message-Id: <20070724.183527.45743058.davem@davemloft.net>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
From: David Miller <davem@davemloft.net>
In-Reply-To: <b21f8390707241826o1422ca3aga9b6516a55dd961d@mail.gmail.com>
References: <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	<20070723221846.d2744f42.akpm@linux-foundation.org>
	<b21f8390707241826o1422ca3aga9b6516a55dd961d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Matthew Hawkins" <darthmdh@gmail.com>
Date: Wed, 25 Jul 2007 11:26:57 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: darthmdh@gmail.com
Cc: akpm@linux-foundation.org, ray-lk@madrabbit.org, nickpiggin@yahoo.com.au, jesper.juhl@gmail.com, linux-kernel@vger.kernel.org, ck@vds.kolivas.org, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

> On 7/24/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > The other consideration here is, as Nick points out, are the problems which
> > people see this patch solving for them solveable in other, better ways?
> > IOW, is this patch fixing up preexisting deficiencies post-facto?
> 
> So let me get this straight - you don't want to merge swap prefetch
> which exists now and solves issues many people are seeing, and has
> been tested more than a gazillion other bits & pieces that do get
> merged - because it could be possible that in the future some other
> patch, which doesn't yet exist and nobody is working on, may solve the
> problem better?

I have to generally agree that the objections to the swap prefetch
patches have been conjecture and in general wasting time and
frustrating people.

There is a point at which it might be wise to just step back and let
the river run it's course and see what happens.  Initially, it's good
to play games of "what if", but after several months it's not a
productive thing and slows down progress for no good reason.

If a better mechanism gets implemented, great!  We'll can easily
replace the swap prefetch stuff at such time.  But until then swap
prefetch is what we have and it's sat long enough in -mm with no major
problems to merge it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
