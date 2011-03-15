Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CE6B38D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 17:25:44 -0400 (EDT)
Date: Tue, 15 Mar 2011 22:16:56 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/3 for 2.6.38] oom: oom_kill_process: don't set
	TIF_MEMDIE if !p->mm
Message-ID: <20110315211656.GA28117@redhat.com>
References: <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com> <20110314190446.GB21845@redhat.com> <alpine.DEB.2.00.1103141314190.31514@chino.kir.corp.google.com> <20110315185316.GA21640@redhat.com> <alpine.DEB.2.00.1103151252000.558@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103151252000.558@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/15, David Rientjes wrote:
>
> On Tue, 15 Mar 2011, Oleg Nesterov wrote:
>
> > Confused. I sent the test-case. OK, may be you meant the code in -mm,
> > but I meant the current code.
> >
>
> This entire discussion, and your involvement in it, originated from these
> two patches being merged into -mm:
>
> 	oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch
> 	oom-skip-zombies-when-iterating-tasklist.patch

Yes. This motivated me to look at the current code, and I was unpleasantly
surprised.

> So naturally I'm going to challenge your testcases with the latest -mm.

Sure. And once again, I didn't expect the 2nd problem was fixed, I forgot
about the second patch.

> If you wanted to suggest pushing these to 2.6.38 earlier,

Yes. It was too late for 2.6.38. I thought we have more time before
release.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
