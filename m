Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 2A8246B005A
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:27:11 -0500 (EST)
Message-ID: <1324448829.21735.4.camel@joe2Laptop>
Subject: Re: [PATCH] vmalloc: remove #ifdef in function body
From: Joe Perches <joe@perches.com>
Date: Tue, 20 Dec 2011 22:27:09 -0800
In-Reply-To: <20111221060739.GD28505@barrios-laptop.redhat.com>
References: <1324444679-9247-1-git-send-email-minchan@kernel.org>
	 <1324445481.20505.7.camel@joe2Laptop>
	 <20111221054531.GB28505@barrios-laptop.redhat.com>
	 <1324447099.21340.6.camel@joe2Laptop>
	 <20111221060739.GD28505@barrios-laptop.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-12-21 at 15:07 +0900, Minchan Kim wrote:
> On Tue, Dec 20, 2011 at 09:58:19PM -0800, Joe Perches wrote:
> > On Wed, 2011-12-21 at 14:45 +0900, Minchan Kim wrote:
> > > On Tue, Dec 20, 2011 at 09:31:21PM -0800, Joe Perches wrote:
> > > > On Wed, 2011-12-21 at 14:17 +0900, Minchan Kim wrote:
> > > > > We don't like function body which include #ifdef.
> > []
> > > > I don't like this change.
> > > > I think it's perfectly good style to use:
> > > I feel it's no problem as it is because it's very short function now
> > > but it's not style we prefer. 
> > Who is this "we" you refer to?
> > There's nothing suggesting your patch as a preferred style
> > in Documentation/CodingStyle.
> Yes. It doesn't have. 
> But I have thought we have done until now.

But whoever this "we" you're referring to hasn't
actually done so.

> I think we can see them easily.
> 
> #> grep -nRH 'static inline void' ./ | grep {} | wc -l
> 936
> 
> If we consider line which don't include brace in one line, it would be many.

Try:

$ grep -rP --include=*.[ch] \
  '^(static|)\s*(inline|)\s*void\b[^\n;]+\n(?:{\s*|)\#\s*if' * | \
  wc -l
3603

A rough approximation would be to divide by 3.
So there's maybe a 1000 or so of the other style too.

cheers, Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
