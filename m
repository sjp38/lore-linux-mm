Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 9CCAE6B0070
	for <linux-mm@kvack.org>; Tue, 29 May 2012 16:27:00 -0400 (EDT)
Date: Tue, 29 May 2012 13:26:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 3.4-rc7: BUG: Bad rss-counter state mm:ffff88040b56f800 idx:1
 val:-59
Message-Id: <20120529132658.14ab9ba3.akpm@linux-foundation.org>
In-Reply-To: <4FC52F17.20709@openvz.org>
References: <4FBC1618.5010408@fold.natur.cuni.cz>
	<20120522162835.c193c8e0.akpm@linux-foundation.org>
	<20120522162946.2afcdb50.akpm@linux-foundation.org>
	<20120523172146.GA27598@redhat.com>
	<4FC52F17.20709@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>, LKML <linux-kernel@vger.kernel.org>, "markus@trippelsdorf.de" <markus@trippelsdorf.de>, "hughd@google.com" <hughd@google.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 30 May 2012 00:18:31 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Oleg Nesterov wrote:
> > On 05/22, Andrew Morton wrote:
> >>
> >> Also, I have a note here that Oleg was unhappy with the patch.  Oleg
> >> happiness is important.  Has he cheered up yet?
> >
> > Well, yes, I do not really like this patch ;) Because I think there is
> > a more simple/straightforward fix, see below. In my opinion it also
> > makes the original code simpler.
> >
> > But. Obviously this is subjective, I can't prove my patch is "better",
> > and I didn't try to test it.
> >
> > So I won't argue with Konstantin who dislikes my patch, although I
> > would like to know the reason.
> 
> I don't remember why I dislike your patch.
> For now I can only say ACK )

We'll need a changelogged signed-off patch, please Oleg.  And some evidence
that it was tested would be nice ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
