Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB20A6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 10:03:30 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p5DE3RFl018889
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 07:03:27 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq3.eem.corp.google.com with ESMTP id p5DE3MeS004888
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 07:03:26 -0700
Received: by pzk2 with SMTP id 2so2574407pzk.23
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 07:03:22 -0700 (PDT)
Date: Mon, 13 Jun 2011 07:03:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
In-Reply-To: <20110613105410.e06720f1.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1106130655530.28913@sister.anvils>
References: <BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com> <BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com> <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1106091812030.4904@sister.anvils>
 <20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com> <20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com> <20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com> <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1106101425400.28334@sister.anvils>
 <20110610235442.GA21413@cmpxchg.org> <20110611175136.GA31154@cmpxchg.org> <alpine.LSU.2.00.1106121828220.31463@sister.anvils> <20110613105410.e06720f1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 13 Jun 2011, KAMEZAWA Hiroyuki wrote:
> On Sun, 12 Jun 2011 18:41:58 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> > 
> > The version I've signed off and am actually testing is below;
> > but I've not had enough time to spare on the machine which reproduced
> > it before, and another I thought I'd delegate it to last night,
> > failed to reproduce without the patch.  Try again tonight.
> > 
> > Thought I'd better respond despite inadequate testing, given the flaw
> > in the posted patch.  Hope the one below is flawless.
> > 
> 
> Thank you, I'll do test, too.

I confirm it fixes the bug: ran ten hours last night, when a couple
of tries just before without the patch each failed in ten minutes.

(But the load was not testing whether it keeps ownership when it should,
I hope you know a quick check on that: our earlier fixes should fail that.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
