Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA13987
	for <linux-mm@kvack.org>; Sat, 21 Sep 2002 18:49:55 -0700 (PDT)
Message-ID: <3D8D21C2.FFE42453@digeo.com>
Date: Sat, 21 Sep 2002 18:49:54 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: overcommit stuff
References: <3D8D17B6.D4E1ECAE@digeo.com> <Pine.LNX.4.44.0209220238560.2497-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> 
> On Sat, 21 Sep 2002, Andrew Morton wrote:
> > Hugh Dickins wrote:
> > > ...
> > > > It seems very unlikely (impossible?) that those pages will
> > > > ever become unshared.
> > >
> > > I expect it's very unlikely (short of application bugs) that
> > > those pages would become unshared; but they have been mapped
> > > in such a way that the process is entitled to unshare them,
> > > therefore they have been counted.  A good example of why
> > > Linux does not impose strict commit accounting, and why
> > > you may choose not to use Alan's strict accounting policy.
> >
> > OK, thanks.   Just checking.
> >
> > Is glibc mapping executables with PROT_WRITE?  If so,
> > doesn't that rather devalue the whole overcommit thing?
> 
> No, it looks like glibc is doing the right thing (mapping the code
> readonly and the data+bss readwrite).  And I was wrong to say it's
> unlikely those pages would ever become unshared: the four 0.5MB
> areas look like typical readwrite private anon allocations.
> 

hm.  That would be two megs of real memory per task?  So maybe
I wasn't running 10000 tasks.  It's hard to say - running ps
with that many processes in the machine appears to take longer
than I have left on this earth.

Maybe an `ls /proc | wc' would tell me.  Dunno; I've moved onto
other bugs for today.  Bill seems to be into this stuff.  Hopefully
he'll retest on the next -mm, which should be a bit nicer to
those-who-run-too-many-tiobenches.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
