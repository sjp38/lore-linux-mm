Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B10556B004D
	for <linux-mm@kvack.org>; Sun,  8 Nov 2009 12:05:02 -0500 (EST)
Date: Sun, 8 Nov 2009 18:04:53 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] show per-process swap usage via procfs
Message-ID: <20091108170453.GA1372@ucw.cz>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1> <20091105082357.54D3.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0911051003060.25718@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0911051003060.25718@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu 2009-11-05 10:04:01, Christoph Lameter wrote:
> On Thu, 5 Nov 2009, KOSAKI Motohiro wrote:
> 
> > > On Wed, 4 Nov 2009, KAMEZAWA Hiroyuki wrote:
> > >
> > > > Now, anon_rss and file_rss is counted as RSS and exported via /proc.
> > > > RSS usage is important information but one more information which
> > > > is often asked by users is "usage of swap".(user support team said.)
> > >
> > > Hmmm... Could we do some rework of the counters first so that they are per
> > > cpu?
> >
> > per-cpu swap counter?
> > It seems overkill effort....
> 
> The other alternative is to use atomic ops which are significantly slower
> and have an impact on critical sections.

...but compared to disk i/o, overhead should be almost zero, right?
Keep it simple...

								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
