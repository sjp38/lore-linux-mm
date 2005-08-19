Received: by wproxy.gmail.com with SMTP id i6so909842wra
        for <linux-mm@kvack.org>; Fri, 19 Aug 2005 13:20:16 -0700 (PDT)
Message-ID: <e692861c050819132017971a1a@mail.gmail.com>
Date: Fri, 19 Aug 2005 16:20:16 -0400
From: Gregory Maxwell <gmaxwell@gmail.com>
Subject: Re: Preswapping
In-Reply-To: <Pine.LNX.4.62.0508191137350.15836@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <e692861c05081814582671a6a3@mail.gmail.com>
	 <Pine.LNX.4.62.0508191137350.15836@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/19/05, Christoph Lameter <clameter@engr.sgi.com> wrote:
> On Thu, 18 Aug 2005, Gregory Maxwell wrote:
> 
> > With the ability to measure something approximating least frequently
> > used inactive pages now, would it not make sense to begin more
> > aggressive nonevicting preswapping?
> 
> Maybe. What would be the overhead for cases in which swapping is not
> needed?

Extraneous disk IO, perhaps a little extra overhead in having another
list to walk.. Oddball additional allocations on the swap partition.

I think none of these would be insurmountable obstacles.  Write out
should heed the laptop mode setting to avoid spinning up the disk..
the activity should be suppressed whenever the disk is busy.

This also puts things in potentially better shape so that things can
be swapped out in nice contiguous runs and swapped-in with nice
contiguous runs.

A further step might be to arrange things so that preemptive swapping
and swsup shared many of the same structures.. so a preemptive
swapping box would just be perpetually setting up it's freeze.. a
suspend to disk would just require quiesce the processes and pushing
out the (hopefully few) remaining pages.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
