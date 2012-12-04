Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 4830D6B0062
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 14:51:12 -0500 (EST)
Date: Tue, 4 Dec 2012 14:50:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121204195008.GD24381@cmpxchg.org>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
 <20121128094511.GS8218@suse.de>
 <50BCC3E3.40804@redhat.com>
 <20121203191858.GY24381@cmpxchg.org>
 <50BDBCD9.9060509@redhat.com>
 <50BDBF1D.60105@suse.cz>
 <20121204161131.GB24381@cmpxchg.org>
 <50BE234E.7000603@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BE234E.7000603@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Zdenek Kabelac <zkabelac@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Thorsten Leemhuis <fedora@leemhuis.info>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis.Kletnieks@vt.edu, Bruno Wolff III <bruno@wolff.to>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 04, 2012 at 05:22:38PM +0100, Jiri Slaby wrote:
> On 12/04/2012 05:11 PM, Johannes Weiner wrote:
> >>>> Any chance you could retry with this patch on top?
> >>
> >> It does not apply to -next :/. Should I try anything else?
> > 
> > The COMPACTION_BUILD changed to IS_ENABLED(CONFIG_COMPACTION), below
> > is a -next patch.  I hope you don't run into other problems that come
> > out of -next craziness, because Linus is kinda waiting for this to be
> > resolved to release 3.8.  If you've always tested against -next so far
> > and it worked otherwise, don't change the environment now, please.  If
> > you just started, it would make more sense to test based on 3.7-rc8.
> 
> I reported the issue as soon as it appeared in -next for the first time
> on Oct 12. Since then I'm constantly hitting the issue (well, there were
> more than one I suppose, but not all of them were fixed by now) until
> now. I run only -next...

Okay.  Yes, it was a couple of problems, but not everybody hit the
same subset.

> Going to apply the patch now.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
