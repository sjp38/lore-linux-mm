Date: Mon, 07 Feb 2005 21:46:02 +0900 (JST)
Message-Id: <20050207.214602.84973729.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <42039E19.9060609@sgi.com>
References: <420240F8.6020308@sgi.com>
	<20050204.163248.41633006.taka@valinux.co.jp>
	<42039E19.9060609@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@sgi.com
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi Ray,

> >>If I take out the migration cache patch, this "VM: killing ..." problem
> >>goes away.   So it has something to do specifically with the migration
> >>cache code.
> > 
> > 
> > I've never seen the message though the migration cache code may have
> > some bugs. May I ask you some questions about it?
> > 
> >  - Which version of kernel did you use for it?
> 
> 2.6.10.  I pulled enough of the mm fixes (2 patches) so that the base
> migration patch from the hotplug tree would work on top of 2.6.10.  AFAIK
> the same problem occurs on 2.6.11-mm2 which is where I started with the
> migration cache patch.  But I admit I haven't tested it there recently.

(snip)

> >  - Is it possible to make the same problem on my machine?
> 
> I think so.  I'd have to send you my system call code and test programs.
> Its not a lot of code on top of the existing page migration patch.

Ok, would you post the code on the list?
I'll take a look at it and run on my box.

> > And, would you please make your project proceed without the
> > migration cache code for a while?
> 
> I've already done that.  :-)

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
