Date: Thu, 26 Jul 2007 11:13:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
Message-Id: <20070726111326.873f7b0a.akpm@linux-foundation.org>
In-Reply-To: <b14e81f00707260719w63d8ab38jbf2a17a38bd07c1d@mail.gmail.com>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	<46A58B49.3050508@yahoo.com.au>
	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	<46A6CC56.6040307@yahoo.com.au>
	<46A6D7D2.4050708@gmail.com>
	<1185341449.7105.53.camel@perkele>
	<46A6E1A1.4010508@yahoo.com.au>
	<2c0942db0707250909r435fef75sa5cbf8b1c766000b@mail.gmail.com>
	<20070725215717.df1d2eea.akpm@linux-foundation.org>
	<b14e81f00707260719w63d8ab38jbf2a17a38bd07c1d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Chang <thenewme91@gmail.com>
Cc: Ray Lee <ray-lk@madrabbit.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Eric St-Laurent <ericstl34@sympatico.ca>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Jesper Juhl <jesper.juhl@gmail.com>, Rene Herman <rene.herman@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jul 2007 10:19:06 -0400 "Michael Chang" <thenewme91@gmail.com> wrote:

> > All this would end up needing runtime configurability and tweakability and
> > customisability.  All standard fare for userspace stuff - much easier than
> > patching the kernel.
> 
> Maybe I'm missing something here, but if the problem is resource
> allocation when switching from state A to state B, and from B to C,
> etc.; wouldn't it be a bad thing if state B happened to be (in the
> future) this state-shifting userspace daemon of which you speak? (Or
> is that likely to be impossible/unlikely for some other reason which
> alludes me at the moment?)

Well.  I was assuming that the daemon wouldn't be a great memory pig. 
I suspect it would do practically zero IO and would use little memory.
It could even be mlocked, but I doubt if that would be needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
