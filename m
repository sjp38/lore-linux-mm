Date: Mon, 2 Oct 2006 21:24:00 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Checking page_count(page) in invalidate_complete_page
Message-Id: <20061002212400.1b5bc690.akpm@osdl.org>
In-Reply-To: <1159849117.5420.17.camel@lade.trondhjem.org>
References: <4518333E.2060101@oracle.com>
	<451870C6.6050008@yahoo.com.au>
	<4518835D.3080702@oracle.com>
	<451886FB.50306@yahoo.com.au>
	<451BF7BC.1040807@oracle.com>
	<20060928093640.14ecb1b1.akpm@osdl.org>
	<20060928094023.e888d533.akpm@osdl.org>
	<451BFB84.5070903@oracle.com>
	<20060928100306.0b58f3c7.akpm@osdl.org>
	<451C01C8.7020104@oracle.com>
	<451C6AAC.1080203@yahoo.com.au>
	<451D8371.2070101@oracle.com>
	<1159562724.13651.39.camel@lappy>
	<451D89E7.7020307@oracle.com>
	<1159564637.13651.44.camel@lappy>
	<20060929144421.48f9f1bd.akpm@osdl.org>
	<451D94A7.9060905@oracle.com>
	<20060929152951.0b763f6a.akpm@osdl.org>
	<451F425F.8030609@oracle.com>
	<4520FFB6.3040801@RedHat.com>
	<1159795522.6143.7.camel@lade.trondhjem.org>
	<20061002095727.05cd052f.akpm@osdl.org>
	<4521460B.8000504@RedHat.com>
	<20061002112005.d02f84f7.akpm@osdl.o! rg>
	<45216233.5010602@RedHat.com>
	<4521C79A.6090102@oracle.com>
	<1159849117.5420.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: chuck.lever@oracle.com, Steve Dickson <SteveD@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 03 Oct 2006 00:18:37 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2006-10-02 at 22:14 -0400, Chuck Lever wrote:
> > Steve Dickson wrote:
> > > Andrew Morton wrote:
> > >>
> > >> This is our user's data we're talking about here.
> > > Point...
> > >
> > >>
> > >> If that printk comes out then we need to fix the kernel so that it no
> > >> longer wants to print that printk.  We don't want to just hide it.
> 
> So what _is_ stopping us from fixing it right now? Are we missing an
> audit of the possible errors? That can be arranged...

We hope that it'll never come out.

> > > I'm concern about the printk popping when we are flushing the
> > > readdir cache (i.e. stale data) and either flooding the console
> > > to a ton a messages (basically bring a system to its knees for
> > > no good reason) or scaring the hell out people by saying we have a
> > > major problem when in reality we are just flushing stale data...
> > > 
> > > So I definitely agree the printk should be there and be on by default,
> > > but I so think it would be a good idea to have way to turn it off
> > > if need be...
> 
> Why? If we know there is a problem, then why wait to fix it?

There is now no known problem.  But as I said before, this is an area where
we've had relatively frequent problems, and those problems are subtle.

So the printk is just an early warning system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
