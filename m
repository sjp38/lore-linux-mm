Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 5E8396B002B
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 11:45:45 -0500 (EST)
MIME-Version: 1.0
Message-ID: <31ca2ed0-d039-4154-bc3d-669d29673706@default>
Date: Fri, 23 Nov 2012 08:45:37 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: behavior of zram stats, and zram allocation limit
References: <CAA25o9Q4gMPeLf3uYJzMNR1EU4D3OPeje24X4PNsUVHGoqyY5g@mail.gmail.com>
 <20121123055144.GC13626@bbox>
In-Reply-To: <20121123055144.GC13626@bbox>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org

> From: Minchan Kim [mailto:minchan@kernel.org]
> Sent: Thursday, November 22, 2012 10:52 PM
> To: Luigi Semenzato
> Cc: linux-mm@kvack.org; Dan Magenheimer
> Subject: Re: behavior of zram stats, and zram allocation limit
>=20
> On Wed, Nov 21, 2012 at 02:58:48PM -0800, Luigi Semenzato wrote:
> > Hi,
> >
> > Two questions for zram developers/users.  (Please let me know if it is
> > NOT acceptable to use this list for these questions.)
> >
> > 1. When I run a synthetic load using zram from kernel 3.4.0,
> > compr_data_size from /sys/block/zram0 seems to decrease even though
> > orig_data_size stays constant (see below).  Is this a bug that was
> > fixed in a later release?  (The synthetic load is a bunch of processes
> > that allocate memory, fill half of it with data from /dev/urandom, and
> > touch the memory randomly.)  I looked at the code and it looks right.
> > :-P
> >
> > 2. Is there a way of setting the max amount of RAM that zram is
> > allowed to allocate?  Right now I can set the size of the
> > *uncompressed* swap device, but how much memory gets allocated depends
> > on the compression ratio, which could vary.
>=20
> There is no method to limit the RAM size but I think we can implement
> it easily. The only thing we need is just a "voice of customer".
> Why do you need it?

Hi Minchan --

I am not an expert on zram, but I do recall a conversation
with hughd in 2010 along this line and, after some thought,
he concluded it was far harder than it sounds.  Since
zram appears as a block device, it is not easy to reject
writes.  Zcache circumvents the block I/O system entirely
so "writes" can be managed much more dynamically.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
