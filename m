Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j36Gsi5j122410
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 12:54:44 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j36Gsibh215198
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 10:54:44 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j36GshSs019311
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 10:54:43 -0600
Date: Wed, 6 Apr 2005 09:48:56 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [ckrm-tech] Re: [PATCH 3/6] CKRM: Add limit support for mem controller
Message-ID: <20050406164856.GA1425@chandralinux.beaverton.ibm.com>
References: <20050402031346.GD23284@chandralinux.beaverton.ibm.com> <1112623850.24676.8.camel@localhost> <20050405174239.GD32645@chandralinux.beaverton.ibm.com> <1112723942.19430.77.camel@localhost> <20050405182620.GF32645@chandralinux.beaverton.ibm.com> <1112727705.19430.121.camel@localhost> <20050405194837.GB1152@chandralinux.beaverton.ibm.com> <1112732985.4200.1973.camel@stark>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1112732985.4200.1973.camel@stark>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Helsley <matthltc@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 05, 2005 at 01:29:45PM -0700, Matthew Helsley wrote:
> On Tue, 2005-04-05 at 12:48, Chandra Seetharaman wrote:
> > On Tue, Apr 05, 2005 at 12:01:45PM -0700, Dave Hansen wrote:
> > > On Tue, 2005-04-05 at 11:26 -0700, Chandra Seetharaman wrote:
> > > > On Tue, Apr 05, 2005 at 10:59:02AM -0700, Dave Hansen wrote:
> > > > > On Tue, 2005-04-05 at 10:42 -0700, Chandra Seetharaman wrote:
> > > > > > On Mon, Apr 04, 2005 at 07:10:50AM -0700, Dave Hansen wrote: 
> > > > > > > What does "impl" stand for, anyway?  implied?  implicit? implemented?
> > > > > > 
> > > > > > I meant implicit... you can also say implied.... will add in comments to
> > > > > > the dats structure definition.
> > > > > 
> > > > > How about changing the name of the structure member?  Comments suck.
> > > > 
> > > > you mean explicit name like implicit_guarantee ? if comments suck, IMHO,
> > > > impl_guar is good enough an option for a field that holds implicit
> > > > guarantee.
> > > 
> > > I think you possibly suffer from an a case of ibmersdontlikevowelsitis
> > > which seems to be endemic to our company.  In case you're wondering,
> > > Linus already found our missing vowels:
> > > 
> > > 	http://www.ussg.iu.edu/hypermail/linux/kernel/0110.1/1294.html
> > 
> > To my knowledge, 'i', 'u' and 'a' are vowels(impl_guar)....  May be I
> > am wrong.. I think I 've relearn my alphabets.
> 
> 	While I agree with Dave's point about 'impl' being vague, I think he's
> just being snarky about the vowels. :)
> 
> > BTW, Can you point me to the latest version ?
> > 
> > Seriously, I don't get your argument that 'impl_guar' doesn't imply
> > implicit guarantee....(especially even after I agreed that I would add some
> > comments)
> 
> 	I think Dave's point is "impl" is an ambiguous prefix. If the intent is
> "implied" or "implicit" then the extra letters are well worth the
> clarification they offer -- more so than any amount of comments since
> the field name will get used in numerous places where the comment is not
> likely to appear.

Adding 3 characters doesn't cost much... but... in this context, what
else could one think "impl" mean ?

One will get the idea if you assume one of implicit implied, or implemented...


> Cheers,
> 	-Matt
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
