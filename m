Date: Tue, 31 Jul 2007 12:46:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070731124642.c43012cd.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707311232580.6093@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain>
	<20070730132314.f6c8b4e1.akpm@linux-foundation.org>
	<20070731000138.GA32468@localdomain>
	<20070730172007.ddf7bdee.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
	<20070731015647.GC32468@localdomain>
	<Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
	<20070730192721.eb220a9d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
	<20070730214756.c4211678.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
	<20070730221736.ccf67c86.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707302224190.30889@schroedinger.engr.sgi.com>
	<20070730225809.ed0a95ff.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707302300090.874@schroedinger.engr.sgi.com>
	<20070730231806.da72a7ec.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707311232580.6093@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007 12:35:03 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 30 Jul 2007, Andrew Morton wrote:
> 
> > On Mon, 30 Jul 2007 23:09:09 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > > OK, plausible.  But where's the *proof*?  We probably already have 
> > > > sufficient statistics to be able to prove this.
> > > 
> > > Rik has shown this repeatedly.
> > 
> > url?
> 
> F.e.
> 
> http://linux-mm.org/ProblemWorkloads
> 
> http://lwn.net/Articles/224850/

They're different from Kiran's problem.  Not specifically ramfs and
zone-reclaim isn't (obviously) involved.  Yes, the solution is probably the
same one, but it'd be sad to "fix" Kiran's problem via finer-grained zone
accounting while leaving an undiscovered bug behind.

If we're going further down that path we should aim at removing the
all_unreclaimable logic completely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
