Message-ID: <3D88A575.D25CE720@austin.ibm.com>
Date: Wed, 18 Sep 2002 11:10:30 -0500
From: Bill Hartner <bhartner@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: VolanoMark Benchmark results for 2.5.26, 2.5.26 + rmap, 2.5.35,and  
 2.5.35 + mm1
References: <Pine.LNX.4.44L.0209172219200.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@digeo.com>, Bill Hartner <hartner@austin.ibm.com>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>


Rik van Riel wrote:
> 
> On Tue, 17 Sep 2002, Andrew Morton wrote:
> > Bill Hartner wrote:
> > >
> > > I ran VolanoMark 2.1.2 under memory pressure to test rmap.
> > >                              ---------------

> > > 2.5.26 vs 2.5.26 + rmap patch
> > > -----------------------------
> > > It appears as though the page stealing decisions made when using the
> > > 2.5.26 rmap patch may not be as good as the baseline for this workload.
> > > There was more swap activity and idle time.
> >
> > Do you have similar results for 2.4 and 2.4-rmap?
> 
> If Bill is going to test this, I'd appreciate it if he could use
> rmap14a (or newer, if I've released it by the time he gets around
> to testing).
> 

Rik,

I will baseline on 2.4.19 and run both the 3GB and 4GB VoloanoMark test.

I will also test with rmap14a.

I am currently running (a) rawio on scsi devices and (b) direct io on scsi
devices for both read and readv on 2.5.35.  For this test, I am using an
8-way 700 Mhz with (4) IBM 4Mx controllers and 32 disks.

I should be able to get to the 2.4.19 VolanoMark tests by the end of the week.
Both rawio and VolanoMark test use the same machine.

Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
