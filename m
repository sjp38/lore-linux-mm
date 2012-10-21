Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 6F0486B0062
	for <linux-mm@kvack.org>; Sun, 21 Oct 2012 08:31:53 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so1319477wgb.26
        for <linux-mm@kvack.org>; Sun, 21 Oct 2012 05:31:51 -0700 (PDT)
Date: Sun, 21 Oct 2012 14:31:47 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: question on NUMA page migration
Message-ID: <20121021123147.GB19229@gmail.com>
References: <5081777A.8050104@redhat.com>
 <50836060.4050408@gmail.com>
 <5083608E.6040209@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5083608E.6040209@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ni zhan Chen <nizhan.chen@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>


* Rik van Riel <riel@redhat.com> wrote:

> On 10/20/2012 10:39 PM, Ni zhan Chen wrote:
> >On 10/19/2012 11:53 PM, Rik van Riel wrote:
> >>Hi Andrea, Peter,
> >>
> >>I have a question on page refcounting in your NUMA
> >>page migration code.
> >>
> >>In Peter's case, I wonder why you introduce a new
> >>MIGRATE_FAULT migration mode. If the normal page
> >>migration / compaction logic can do without taking
> >>an extra reference count, why does your code need it?
> >
> >Hi Rik van Riel,
> >
> >This is which part of codes? Why I can't find MIGRATE_FAULT in latest
> >v3.7-rc2?
> 
> It is in tip.git in the numa/core branch.

The Git access URI is:

  git pull  git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git numa/core
  git clone git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git numa/core

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
