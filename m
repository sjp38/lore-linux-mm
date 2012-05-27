Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 49EC66B0082
	for <linux-mm@kvack.org>; Sun, 27 May 2012 18:30:01 -0400 (EDT)
Received: by wefh52 with SMTP id h52so2361372wef.14
        for <linux-mm@kvack.org>; Sun, 27 May 2012 15:29:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120524202221.GA19856@phenom.dumpdata.com>
References: <20120518204211.GA18571@localhost.localdomain> <20120524202221.GA19856@phenom.dumpdata.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 27 May 2012 15:29:39 -0700
Message-ID: <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
Subject: Re: [GIT] (frontswap.v16-tag)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, chris.mason@oracle.com, matthew@wil.cx, ngupta@vflare.org, hannes@cmpxchg.org, hughd@google.com, sjenning@linux.vnet.ibm.com, JBeulich@novell.com, dan.magenheimer@oracle.com, linux-mm@kvack.org

On Thu, May 24, 2012 at 1:22 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
>
> I posted this while I was on vacation and just realized that I hadn't
> put in the usual "GIT PULL" subject. Sorry about that - so sending
> this in case this GIT PULL got lost in your 'not-git-pull-ignore-for-two-weeks'
> folder. Cheers!

So that isn't actually the main reason I hadn't pulled, although being
emailed a few days before the merge window opened did mean that it was
fairly low down in my mailbox anyway..

No, the real reason is that for new features like this - features that
I don't really see myself using personally and that I'm not all that
personally excited about - I *really* want others to pipe up with
"yes, we're using this, and yes, we want this to be merged".

It doesn't seem to be huge, which is great, but the deathly silence of
nobody speaking up and saying "yes please", makes me go "ok, I won't
pull if nobody speaks up for the feature".

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
