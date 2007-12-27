Date: Thu, 27 Dec 2007 11:43:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB
In-Reply-To: <4773CBD2.10703@hp.com>
Message-ID: <Pine.LNX.4.64.0712271141390.30555@schroedinger.engr.sgi.com>
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com>
 <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com>
 <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com>
 <4773CBD2.10703@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Seger <Mark.Seger@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Dec 2007, Mark Seger wrote:

>                           <-------- objects --------><----- slabs
> -----><------ memory ------>
> Slab Name                     Size   In Use    Avail     Size   Number Used       Total
> :0000008                         8     2164     2560     4096        5 17312       20480

The right hand side is okay. Could you list all the slab names that are 
covered by :00008 on the left side (maybe separated by commas?) Having the 
:00008 there is ugly. slabinfo can show you a way how to get the names.

> There are all sorts of other ways to present the data such as percentages,
> differences, etc. but this is more-or-less the way I did it in the past and
> the information was useful.  One could also argue that the real key
> information here is Uses/Total and the rest is just window dressing and I
> couldn't disagree with that either, but I do think it helps paint a more
> complete picture.

I agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
