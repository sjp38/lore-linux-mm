Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
From: Daniel Walker <dwalker@mvista.com>
In-Reply-To: <170fa0d20705041109j1d130456p4b7cef3633f8edb4@mail.gmail.com>
References: <20070504102651.923946304@chello.nl>
	 <1178292179.7997.12.camel@imap.mvista.com>
	 <1178293081.24217.46.camel@twins>
	 <1178294379.7997.26.camel@imap.mvista.com>
	 <170fa0d20705041109j1d130456p4b7cef3633f8edb4@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 04 May 2007 12:31:26 -0700
Message-Id: <1178307086.7997.75.camel@imap.mvista.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Snitzer <snitzer@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@steeleye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-04 at 14:09 -0400, Mike Snitzer wrote:
> On 5/4/07, Daniel Walker <dwalker@mvista.com> wrote:
> > On Fri, 2007-05-04 at 17:38 +0200, Peter Zijlstra wrote:
> > > >
> > > > This is kind of a lot of patches all at once .. Have you release any of
> > > > these patch sets prior to this release ?
> > >
> > > Like the -v12 suggests, this is the 12th posting of this patch set.
> > > Some is the same, some has changed.
> >
> > I can find one prior release with this subject (-v11) , what was the
> > subject prior to that release? It's not a hard rule, but usually >15
> > patches is too many (check Documentation/SubmittingPatches under
> > references).. You might want to consider submitting a URL instead.
> 
> Previous subjects were like:
> [PATCH 00/20] vm deadlock avoidance for NFS, NBD and iSCSI (take 7)
> 
> A URL doesn't allow for true discussion about a particular patch
> unless the reviewer takes the initiative to create a new thread to
> discuss the Nth patch it a patchset; whereby taking on the burden of a
> structured subject and so on.  It would get out of control on a large
> patchset that actually got a lot of simultaneous feedback... reviewers
> don't have a forum to talk about each individual change without
> stepping on each others' toes.

True ..

> > I think it's a benefit to release less since a developer (like myself)
> > might know very little about "Swap over Networked storage", but if you
> > submit 10 patches that developer might still review it, 40 patches they
> > likely wouldn't review it.
> 
> The _suggestions_ in Documentation/SubmittingPatches are nice and all
> but the quantity of patches shouldn't _really_ matter.

I guess I take the documentation more seriously than your do. It's
clearly not mandatory, but for my reviewing I appreciate less then 15
sets of "logical changes".

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
