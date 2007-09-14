Date: Fri, 14 Sep 2007 14:14:47 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH -mm] mm: Fix memory hotplug + sparsemem build.
In-Reply-To: <20070913194130.1611fd78.akpm@linux-foundation.org>
References: <20070914105420.F2E9.Y-GOTO@jp.fujitsu.com> <20070913194130.1611fd78.akpm@linux-foundation.org>
Message-Id: <20070914115045.F2EB.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Paul Mundt <lethal@linux-sh.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 14 Sep 2007 11:02:43 +0900 Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> 
> > > >  	/* call arch's memory hotadd */
> > > > 
> > > 
> > > OK, we're getting into a mess here.  This patch fixes
> > > update-n_high_memory-node-state-for-memory-hotadd.patch, but which patch
> > > does update-n_high_memory-node-state-for-memory-hotadd.patch fix?
> > > 
> > > At present I just whacked
> > > update-n_high_memory-node-state-for-memory-hotadd.patch at the end of
> > > everything, but that was lazy of me and it ends up making a mess.
> > 
> > It is enough. No more patch is necessary for these issues.
> > I already fixed about Andy-san's comment. :-)
> 
> Now I'm more confused.  I have two separeate questions:
> 
> a) Is the justr-added update-n_high_memory-node-state-for-memory-hotadd-fix.patch
>    still needed?

I'm not sure exact meaning of "just-added". 
But, update-n_high_memory-node-state-for-memory-hotadd-fix.patch is
necessary for 2.6.23-rc4-mm1.

> b) Which patch in 2.6.22-rc4-mm1 does

                    2.6.23-rc4-mm1?

>    update-n_high_memory-node-state-for-memory-hotadd.patch fix?  In other
>    words, into which patch should I fold
>    update-n_high_memory-node-state-for-memory-hotadd.patch prior to sending
>    to Linus?

In my understanding, 
update-n_high_memory-node-state-for-memory-hotadd.patch should be folded
with all of memoryless-nodes-xxxxxxxxxxxx.patch.
It sets N_HIGH_MEMORY for a new node-with-memory.

But if you need specifing of more detail patch, becase N_HIGH_MEMORY is
set in memoryless-nodes-introduce-ask-of-nodes-with-memory.patch, 
I suppose update-n_high_memory-node-state-for-memory-hotadd.patch
should be fold with it.


update-n_high_memory-node-state-for-memory-hotadd-fix.patch
                                                  ^^^
is fixes of update-n_high_memory-node-state-for-memory-hotadd.patch
and memoryless-nodes-no-need-for-kswapd.patch


Is it enough for your question? Or more confuse?


>    (I (usually) get to work this out for myself.  Sometimes it is painful).
> 
> Generally, if people tell me which patch-in-mm their patch is fixing,
> it really helps.  Adrian does this all the time.

Sorry for your confusing...


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
