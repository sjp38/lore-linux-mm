Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A216B6B0083
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 18:54:47 -0500 (EST)
From: Andres Freund <andres@anarazel.de>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
Date: Fri, 29 Jan 2010 00:54:40 +0100
References: <20100120215712.GO27212@frostnet.net> <alpine.DEB.1.00.1001272319530.2909@abydos.NerdBox.Net> <20100128002313.2b94344e.akpm@linux-foundation.org>
In-Reply-To: <20100128002313.2b94344e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001290054.42246.andres@anarazel.de>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steve VanDeBogart <vandebo-lkml@nerdbox.net>, Chris Frost <frost@cs.ucla.edu>, Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 28 January 2010 09:23:13 Andrew Morton wrote:
> On Wed, 27 Jan 2010 23:42:35 -0800 (PST) Steve VanDeBogart <vandebo-
lkml@NerdBox.Net> wrote:
> > > Is it likely that these changes to SQLite and Gimp would be merged into
> > > the upstream applications?
> > 
> > Changes to the GIMP fit nicely into the code structure, so it's feasible
> > to push this kind of optimization upstream.  The changes in SQLite are
> > a bit more focused on the benchmark, but a more general approach is not
> > conceptually difficult.  SQLite may not want the added complexity, but
> > other database may be interested in the performance improvement.
> > 
> > Of course, these kernel changes are needed before any application can
> > optimize its IO as we did with libprefetch.
> That didn't really answer my question.
> If there's someone signed up and motivated to do the hard work of
> getting these changes integrated into the upstream applications then
> that makes us more interested.  If, however it was some weekend
> proof-of-concept hack which shortly dies an instadeath then...  meh,
> not so much.
There is somebody working on a POC contrib module for postgres to deliver 
better cost estimates using mincore - as postgres doesnt use mmap itself 
something like fincore would be rather nice there.

(While currently it would be contrib module the plan is to be able too hook it 
into it without modifications to core pg code)

Andres

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
