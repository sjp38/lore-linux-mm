Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 1CA7D6B0092
	for <linux-mm@kvack.org>; Thu, 17 May 2012 10:09:54 -0400 (EDT)
Date: Thu, 17 May 2012 09:09:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 1/9] [slob] define page struct fields
 used in mm_types.h
In-Reply-To: <4FB4C7DC.7020309@parallels.com>
Message-ID: <alpine.DEB.2.00.1205170909360.5144@router.home>
References: <20120514201544.334122849@linux.com> <20120514201609.418025254@linux.com> <4FB357C9.8080308@parallels.com> <alpine.DEB.2.00.1205160925410.25603@router.home> <alpine.DEB.2.00.1205161034400.25603@router.home> <4FB4C7DC.7020309@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Thu, 17 May 2012, Glauber Costa wrote:

> On 05/16/2012 07:38 PM, Christoph Lameter wrote:
> > On Wed, 16 May 2012, Christoph Lameter wrote:
> >
> > > >  On Wed, 16 May 2012, Glauber Costa wrote:
> > > >
> > > > >  >  It is of course ok to reuse the field, but what about we make it a
> > > > union
> > > > >  >  between "list" and "lru" ?
> > > >
> > > >  That is what this patch does. You are commenting on code that was
> > > >  removed.
> > Argh. No it doesnt..... It will be easy to add though. But then you have
> > two list_head definitions in page struct that just differ in name.
> As I said previously, it sounds stupid if you look from the typing system
> point of view.
>
> But when I read something like: list_add(&sp->lru, list), something very
> special assumptions about list ordering comes to mind. It's something that
> should be done for the sake of the readers.

Allright will merge the changes that I posted into the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
