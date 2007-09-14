Date: Thu, 13 Sep 2007 19:41:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] mm: Fix memory hotplug + sparsemem build.
Message-Id: <20070913194130.1611fd78.akpm@linux-foundation.org>
In-Reply-To: <20070914105420.F2E9.Y-GOTO@jp.fujitsu.com>
References: <20070911182546.F139.Y-GOTO@jp.fujitsu.com>
	<20070913184456.16ff248e.akpm@linux-foundation.org>
	<20070914105420.F2E9.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Paul Mundt <lethal@linux-sh.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Sep 2007 11:02:43 +0900 Yasunori Goto <y-goto@jp.fujitsu.com> wrote:

> > >  	/* call arch's memory hotadd */
> > > 
> > 
> > OK, we're getting into a mess here.  This patch fixes
> > update-n_high_memory-node-state-for-memory-hotadd.patch, but which patch
> > does update-n_high_memory-node-state-for-memory-hotadd.patch fix?
> > 
> > At present I just whacked
> > update-n_high_memory-node-state-for-memory-hotadd.patch at the end of
> > everything, but that was lazy of me and it ends up making a mess.
> 
> It is enough. No more patch is necessary for these issues.
> I already fixed about Andy-san's comment. :-)

Now I'm more confused.  I have two separeate questions:

a) Is the justr-added update-n_high_memory-node-state-for-memory-hotadd-fix.patch
   still needed?

b) Which patch in 2.6.22-rc4-mm1 does
   update-n_high_memory-node-state-for-memory-hotadd.patch fix?  In other
   words, into which patch should I fold
   update-n_high_memory-node-state-for-memory-hotadd.patch prior to sending
   to Linus?

   (I (usually) get to work this out for myself.  Sometimes it is painful).

Generally, if people tell me which patch-in-mm their patch is fixing,
it really helps.  Adrian does this all the time.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
