From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 1/8] Page host virtual assist: unused / free pages.
Date: Mon, 24 Apr 2006 16:49:24 +0200
References: <20060424123423.GB15817@skybase> <200604241607.15131.ak@suse.de> <1145889670.5241.3.camel@localhost>
In-Reply-To: <1145889670.5241.3.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604241649.24792.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Monday 24 April 2006 16:41, Martin Schwidefsky wrote:
> On Mon, 2006-04-24 at 16:07 +0200, Andi Kleen wrote:
> > On Monday 24 April 2006 14:34, Martin Schwidefsky wrote:
> > 
> > > +#define page_hva_set_unused(_page)		do { } while (0)
> > > +#define page_hva_set_stable(_page)		do { } while (0)
> > 
> > The whole thing seems quite under commented in the code and illnamed
> > (if you didn't know what page_hva_set_unused() is supposed to do
> > already would you figure it out from the name?) 
> 
> Well, we can always add comments if something is unclear. The name
> should give you a good hint though: page-(hva)-set-unused. You set the
> page to the unused state. Is the name really that confusing ?

How about page_set_free / page_set_used ?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
