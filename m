Message-ID: <3D88C91E.26D2A5F1@austin.ibm.com>
Date: Wed, 18 Sep 2002 13:42:38 -0500
From: Bill Hartner <bhartner@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lse-tech] Re: VolanoMark Benchmark results for 2.5.26, 2.5.26 +
 rmap, 2.5.35,and2.5.35 + mm1
References: <Pine.LNX.4.44L.0209181316280.1519-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@digeo.com>, Bill Hartner <hartner@austin.ibm.com>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>


Rik van Riel wrote:
> 
> On Wed, 18 Sep 2002, Bill Hartner wrote:
> 
> > I will baseline on 2.4.19 and run both the 3GB and 4GB VoloanoMark test.
> >
> > I will also test with rmap14a.
> 
> I released rmap14b last night, with an SMP bugfix you'll want to have:
> 
>         http://surriel.com/patches/2.4/2.4.19-rmap14b
> 
> > I am currently running (a) rawio on scsi devices and (b) direct io on scsi
> > devices for both read and readv on 2.5.35.  For this test, I am using an
> > 8-way 700 Mhz with (4) IBM 4Mx controllers and 32 disks.
> 
> Hmmm, with near certainty rmap in 2.4 still has a bunch of SMP
> inefficiencies that'll slow you down on an 8-way. If these are
> bothering you I'll do a backport of the 2.5 rmap speedups...

I have not ran on a UP with memory pressure - could try that.

VolanoMark has looooooong run queues - so I will look for a o(1) 
scheduler patch to lay down and then rmap14b - do you see any problem
with rmap14b on top of o(1) ?

Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
