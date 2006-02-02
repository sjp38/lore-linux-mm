Date: Thu, 2 Feb 2006 12:54:02 +0900
From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Subject: Re: [ckrm-tech] [PATCH 0/8] Pzone based CKRM memory resource
 controller
In-Reply-To: <1138843560.3939.26.camel@localhost.localdomain>
References: <20060119080408.24736.13148.sendpatchset@debian>
	<20060131023000.7915.71955.sendpatchset@debian>
	<1138762698.3938.16.camel@localhost.localdomain>
	<20060201053958.CE35B74035@sv1.valinux.co.jp>
	<1138843560.3939.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20060202035402.A29667403A@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 01 Feb 2006 17:26:00 -0800
chandra seetharaman <sekharan@us.ibm.com> wrote:

> > >  - what is the plan to support "limit" ?
> > 
> > To be honest, I don't have any specific idea to support "limit" currently.
> > Probably the userspace daemon that enlarge "guarantee" to the specified
> > "limit" might support the "limit", because "guarantee" in the pzone based 
> > memory resource controller also works as "limit".
> 
> I am not able to visualize how this will work.
> 
> In simple terms, sum of guarantees should _not_ exceed the amount of
> available memory but, sum of limits _can_ exceed the amount of available
> memory. As far as i understand your implementation, guarantee is
> translated to present_pages of the pseudo zone (and is subtracted from
> paren't present_pages). How can one set limit to be same as guarantee ?

The number of pages in the pseudo zones can also be considered as limit
because tasks in a class can't allocate beyond the number of the pages
that are allocated to the pseudo zones.  

> > >  - can you provide more information in stats ?
> > 
> > Ok, I'll do that.
> > 
> > >  - is it designed to work with cpumeter alone (i.e without ckrm) ?
> > 
> > Maybe it works with cpumeter.
> 
> have you tested it without ckrm (i mean only with cpumeter)

The patches I had sent don't include a harness to cpumeter, so 
we can't run with cpumeter.  I suppose we need little work for modifying
mm/mem_rc_pzone.c to work with cpumeter because the file was originally 
written for cpumeter.

-- 
KUROSAWA, Takahiro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
