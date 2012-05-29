Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id E17786B0068
	for <linux-mm@kvack.org>; Tue, 29 May 2012 10:09:36 -0400 (EDT)
Date: Tue, 29 May 2012 10:02:44 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [GIT] (frontswap.v16-tag)
Message-ID: <20120529140244.GA3558@phenom.dumpdata.com>
References: <20120518204211.GA18571@localhost.localdomain>
 <20120524202221.GA19856@phenom.dumpdata.com>
 <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, chris.mason@oracle.com, matthew@wil.cx, ngupta@vflare.org, hannes@cmpxchg.org, hughd@google.com, sjenning@linux.vnet.ibm.com, JBeulich@novell.com, dan.magenheimer@oracle.com, linux-mm@kvack.org

On Sun, May 27, 2012 at 03:29:39PM -0700, Linus Torvalds wrote:
> On Thu, May 24, 2012 at 1:22 PM, Konrad Rzeszutek Wilk
> <konrad.wilk@oracle.com> wrote:
> >
> > I posted this while I was on vacation and just realized that I hadn't
> > put in the usual "GIT PULL" subject. Sorry about that - so sending
> > this in case this GIT PULL got lost in your 'not-git-pull-ignore-for-two-weeks'
> > folder. Cheers!
> 
> So that isn't actually the main reason I hadn't pulled, although being
> emailed a few days before the merge window opened did mean that it was
> fairly low down in my mailbox anyway..

Ah, I was thinking that you might have gotten bored during that weekend
and would pounce on some new code :-) I was probably projecting as I
was near the vacation and needed my code-fix.

> 
> No, the real reason is that for new features like this - features that
> I don't really see myself using personally and that I'm not all that
> personally excited about - I *really* want others to pipe up with
> "yes, we're using this, and yes, we want this to be merged".
> 
> It doesn't seem to be huge, which is great, but the deathly silence of
> nobody speaking up and saying "yes please", makes me go "ok, I won't
> pull if nobody speaks up for the feature".

Ooh, Wim Coekaerts just posted over the weekend a blog about his excitement
about it: https://blogs.oracle.com/wim/entry/from_the_research_department_ramster

Also over the last couple of months I had gotten emails about people
using it. Let me see if I can get their consent to either quote their
emails or just ask them to reply to this thread.

Also both Jan (SuSE) and Seth (IBM) are equally excited about this
code as it is being used in a distro and in embedded hardware.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
