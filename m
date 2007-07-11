Date: Wed, 11 Jul 2007 09:50:53 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: swap prefetch (Re: -mm merge plans for 2.6.23)
Message-ID: <20070711075053.GA20094@elte.hu>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <200707102015.44004.kernel@kolivas.org> <b21f8390707101802o2d546477n2a18c1c3547c3d7a@mail.gmail.com> <20070710181419.6d1b2f7e.akpm@linux-foundation.org> <b21f8390707101954s3ae69db8vc30287277941cb1f@mail.gmail.com> <4694683B.3060705@yahoo.com.au> <2c0942db0707102247n3b6e5933i9803a2161d6c00b1@mail.gmail.com> <469470A3.5040606@yahoo.com.au> <2c0942db0707102304s3f666eceib454043c716e2178@mail.gmail.com> <46947784.6050100@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46947784.6050100@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ray Lee <ray-lk@madrabbit.org>, Matthew Hawkins <darthmdh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Con Kolivas <kernel@kolivas.org>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Regarding swap prefetching. I'm not going to argue for or against it 
> anymore because I have really stopped following where it is up to, for 
> now. If the code and the results meet the standard that Andrew wants 
> then I don't particularly mind if he merges it.

I have tested it and have read the code, and it looks fine to me. (i've 
reported my test results elsewhere already) We should include this in 
v2.6.23.

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
