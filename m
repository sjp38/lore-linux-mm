Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 571BD6B004D
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 21:07:26 -0500 (EST)
Received: by iajr24 with SMTP id r24so2080509iaj.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 18:07:25 -0800 (PST)
Date: Thu, 8 Mar 2012 18:06:50 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/7 v2] mm: rework __isolate_lru_page() file/anon
 filter
In-Reply-To: <20120308143034.f3521b1e.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1203081758490.18195@eggly.anvils>
References: <20120229091547.29236.28230.stgit@zurg> <20120303091327.17599.80336.stgit@zurg> <alpine.LSU.2.00.1203061904570.18675@eggly.anvils> <20120308143034.f3521b1e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Mar 2012, KAMEZAWA Hiroyuki wrote:
> On Tue, 6 Mar 2012 19:22:21 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> > 
> > What does the compiler say (4.5.1 here, OPTIMIZE_FOR_SIZE off)?
> >    text	   data	    bss	    dec	    hex	filename
> >   17723	    113	     17	  17853	   45bd	vmscan.o.0
> >   17671	    113	     17	  17801	   4589	vmscan.o.1
> >   17803	    113	     17	  17933	   460d	vmscan.o.2
> > 
> > That suggests that your v2 is the worst and your v1 the best.
> > Kame, can I persuade you to let the compiler decide on this?
> > 
> 
> Hmm. How about Costa' proposal ? as
> 
> int tmp_var = PageActive(page) ? ISOLATE_ACTIVE : ISOLATE_INACTIVE
> if (!(mode & tmp_var))
>     ret;

Yes, that would have been a good compromise (given a better name
than "tmp_var"!), I didn't realize that one was acceptable to you.

But I see that Konstantin has been inspired by our disagreement to a
more creative solution.

I like very much the look of what he's come up with, but I'm still
puzzling over why it barely makes any improvement to __isolate_lru_page():
seems significantly inferior (in code size terms) to his original (which
I imagine Glauber's compromise would be equivalent to).

At some point I ought to give up on niggling about this,
but I haven't quite got there yet.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
