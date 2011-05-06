Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9006B0023
	for <linux-mm@kvack.org>; Fri,  6 May 2011 03:15:43 -0400 (EDT)
Date: Fri, 6 May 2011 09:15:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH resend] mm: get rid of CONFIG_STACK_GROWSUP || CONFIG_IA64
Message-ID: <20110506071534.GA32495@tiehlicka.suse.cz>
References: <20110503141044.GA25351@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1105031142260.7349@sister.anvils>
 <20110504083005.GA1375@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1105041016110.23159@sister.anvils>
 <20110505063012.GA11529@tiehlicka.suse.cz>
 <BANLkTikGduoi8DVapz0H-uVPrrXPYF=YGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikGduoi8DVapz0H-uVPrrXPYF=YGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 05-05-11 18:12:12, Hugh Dickins wrote:
> On Wed, May 4, 2011 at 11:30 PM, Michal Hocko <mhocko@suse.cz> wrote:
> 
> > So I think the flag should be used that way. If we ever going to add a
> > new architecture like IA64 which uses both ways of expanding we should
> > make it easier by minimizing the places which have to be examined.
> 
> If, yes.  Let's just agree to disagree.  It looks like I'm preferring
> to think of the ia64 case as exceptional, and I want to be reminded of
> that peculiar case; whereas you are wanting to generalize and make it
> not stand out.  Both valid.

Probably a call for Andrew?
Anyway, whatever is the way we go I think that both declaration and
definition should be guarded by the same ifdefs.

> > OK, now, with the cleanup patch, we have expand_stack and
> > expand_stack_{downwards,upwards}. I will repost the patch to Andrew with
> > up and down cases renamed. Does it work for you?
> 
> Sounds right.

OK, I will repost the updated patch.

> >> But it's always going to be somewhat confusing and asymmetrical
> >> because of the ia64 register backing store case.
> >
> > How come? We would have expand_stack which is pretty much clear that it
> > is expanding stack in the architecture specific way. And then we would
> > have expand_{upwards,downward} which are clear about way how we expand
> > whatever VMA, right?
> 
> Right.  I'm preferring to be reminded of the confusion and asymmetry,
> you're preferring to smooth over it.

OK

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
