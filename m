Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j35IVu4I399636
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 14:31:56 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j35IVtHO168488
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 12:31:55 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j35IVtZc019913
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 12:31:55 -0600
Date: Tue, 5 Apr 2005 11:26:20 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [PATCH 3/6] CKRM: Add limit support for mem controller
Message-ID: <20050405182620.GF32645@chandralinux.beaverton.ibm.com>
References: <20050402031346.GD23284@chandralinux.beaverton.ibm.com> <1112623850.24676.8.camel@localhost> <20050405174239.GD32645@chandralinux.beaverton.ibm.com> <1112723942.19430.77.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1112723942.19430.77.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 05, 2005 at 10:59:02AM -0700, Dave Hansen wrote:
> On Tue, 2005-04-05 at 10:42 -0700, Chandra Seetharaman wrote:
> > On Mon, Apr 04, 2005 at 07:10:50AM -0700, Dave Hansen wrote:
> > > "DONTCARE" is also multiplexed.  It means "no guarantee" or "no limit"
> > > depending on context.  I don't think it would hurt to have one variable
> > > for each of these cases.
> > 
> > It is agnostic... and the name doesn't suggest one way or other... so, I
> > don't see a problem in multiplexing it.
> 
> I think that variable names should be as suggestive as possible.  *So*
> suggestive that I know what they actually do. :)

I think you mean the macro... It does mean it.... it is a DONT CARE :) be
it limit or guarantee...

> 
> > > What does "impl" stand for, anyway?  implied?  implicit? implemented?
> > 
> > I meant implicit... you can also say implied.... will add in comments to
> > the dats structure definition.
> 
> How about changing the name of the structure member?  Comments suck.

you mean explicit name like implicit_guarantee ? if comments suck, IMHO,
impl_guar is good enough an option for a field that holds implicit
guarantee.
> 
> -- Dave
> 

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
