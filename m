Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: shared pagetable benchmarking
Date: Fri, 27 Dec 2002 10:39:35 +0100
References: <3E02FACD.5B300794@digeo.com> <3E037690.45419D64@digeo.com> <45600000.1040660127@baldur.austin.ibm.com>
In-Reply-To: <45600000.1040660127@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E18RqyB-0001ui-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 23 December 2002 17:15, Dave McCracken wrote:
> >> Let's also not lose sight of what I consider the primary goal of shared
> >> page tables, which is to greatly reduce the page table memory overhead
> >> of massively shared large regions.
> >
> > Well yes.  But this is optimising the (extremely) uncommon case while
> > penalising the (very) common one.
>
> I guess I don't see wasting extra pte pages on duplicated mappings of
> shared memory as extremely uncommon.  Granted, it's not that significant
> for small applications, but it can make a machine unusable with some large
> applications.  I think being able to run applications that couldn't run
> before to be worth some consideration.
>
> I also have a couple of ideas for ways to eliminate the penalty for small
> tasks.  Would you grant that it's a worthwhile effort if the penalty for
> small applications was zero?

Hi Dave, Andrew,

A feature of my original demonstration patch was that I could enable/disable 
sharing with a per-fork granularity.  This is a good thing.  You can use this 
by detecting the case you can't optimize, i.e., forking from bash, and 
essentially using the old code.  The sawoff for improved efficiency comes in 
somewhere over 4 meg worth of shared memory, which just doesn't happen in 
fork+exec from bash.  Then there is always-unshare situation with the stack, 
which I'm sure you're aware of, where it's never worth doing the share.

That said, was not Ingo working on a replacement for fork+exec that doesn't 
do the useless fork?  Would this not make the vast majority of 
impossible-to-optimize cases go away?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
