Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j36IZf5j838038
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 14:35:41 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j36IZfbh200916
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 12:35:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j36IZfuc001597
	for <linux-mm@kvack.org>; Wed, 6 Apr 2005 12:35:41 -0600
Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: [ckrm-tech] Re: [PATCH 3/6] CKRM: Add limit support for mem controller 
In-reply-to: Your message of Wed, 06 Apr 2005 09:48:56 PDT.
             <20050406164856.GA1425@chandralinux.beaverton.ibm.com>
Date: Wed, 06 Apr 2005 11:35:40 -0700
Message-Id: <E1DJFNM-0001nH-00@w-gerrit.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: Matthew Helsley <matthltc@us.ibm.com>, ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 06 Apr 2005 09:48:56 PDT, Chandra Seetharaman wrote:
> On Tue, Apr 05, 2005 at 01:29:45PM -0700, Matthew Helsley wrote:
> > On Tue, 2005-04-05 at 12:48, Chandra Seetharaman wrote:
> > > On Tue, Apr 05, 2005 at 12:01:45PM -0700, Dave Hansen wrote:
> > > > On Tue, 2005-04-05 at 11:26 -0700, Chandra Seetharaman wrote:
> > > > > On Tue, Apr 05, 2005 at 10:59:02AM -0700, Dave Hansen wrote:
> > > > > > On Tue, 2005-04-05 at 10:42 -0700, Chandra Seetharaman wrote:
> > > > > > > On Mon, Apr 04, 2005 at 07:10:50AM -0700, Dave Hansen wrote: 
> > > > > > > > What does "impl" stand for, anyway?  implied?  implicit? implemented?
> > > > > > > 
> > > > > > > I meant implicit... you can also say implied.... will add in comments to
> > > > > > > the dats structure definition.
> > > > > > 
> > > > > > How about changing the name of the structure member?  Comments suck.
> > > > > 
> > > > > you mean explicit name like implicit_guarantee ? if comments suck, IMHO,
> > > > > impl_guar is good enough an option for a field that holds implicit
> > > > > guarantee.
> > > > 
> > > > I think you possibly suffer from an a case of ibmersdontlikevowelsitis
> > > > which seems to be endemic to our company.  In case you're wondering,
> > > > Linus already found our missing vowels:
> > > > 
> > > > 	http://www.ussg.iu.edu/hypermail/linux/kernel/0110.1/1294.html
> > > 
> > > To my knowledge, 'i', 'u' and 'a' are vowels(impl_guar)....  May be I
> > > am wrong.. I think I 've relearn my alphabets.
> > 
> > 	While I agree with Dave's point about 'impl' being vague, I think he's
> > just being snarky about the vowels. :)
> > 
> > > BTW, Can you point me to the latest version ?
> > > 
> > > Seriously, I don't get your argument that 'impl_guar' doesn't imply
> > > implicit guarantee....(especially even after I agreed that I would add some
> > > comments)
> > 
> > 	I think Dave's point is "impl" is an ambiguous prefix. If the intent is
> > "implied" or "implicit" then the extra letters are well worth the
> > clarification they offer -- more so than any amount of comments since
> > the field name will get used in numerous places where the comment is not
> > likely to appear.
> 
> Adding 3 characters doesn't cost much... but... in this context, what
> else could one think "impl" mean ?

Okay - remember that people with no context will occasionally be reading
this code.  So, better names are, well, better.  Being ambiguous with
multiple meaning obviously leads to questions like these.  And for
every question asked, there are 9 more that weren't asked.  So, my
strong recommendation is make the names clear, consistent, and use
them as your first line of documentation defense.

Keep in mind that comments get out of date, where code tends not
to if it is actually used.  ;)  So, fixing the variable names now is
cheap.  This much debate about something indicates a problem that
should be fixed.

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
