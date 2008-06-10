Date: Tue, 10 Jun 2008 12:17:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
In-Reply-To: <20080608165434.67c87e5c.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com>
References: <20080606202838.390050172@redhat.com> <20080606202859.291472052@redhat.com>
 <20080606180506.081f686a.akpm@linux-foundation.org> <20080608163413.08d46427@bree.surriel.com>
 <20080608135704.a4b0dbe1.akpm@linux-foundation.org> <20080608173244.0ac4ad9b@bree.surriel.com>
 <20080608162208.a2683a6c.akpm@linux-foundation.org> <20080608193420.2a9cc030@bree.surriel.com>
 <20080608165434.67c87e5c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jun 2008, Andrew Morton wrote:

> And it will take longer to get those problems sorted out if 32-bt
> machines aren't even compiing the new code in.

The problem is going to be less if we dependedn on 
CONFIG_PAGEFLAGS_EXTENDED instead of 64 bit. This means that only certain 
32bit NUMA/sparsemem configs cannot do this due to lack of page flags.

I did the pageflags rework in part because of Rik's project.

> ho hum.  Can you remind us what problems this patchset actually
> addresses?  Preferably in order of seriousness?  (The [0/n] description
> told us about the implementation but forgot to tell us anything about
> what it was fixing).  Because I guess we should have a think about
> alternative approaches.

It solves the livelock while reclaiming issues that we see more and more.

There are loads that have lots of unreclaimable pages. These are 
frequently and uselessly scanned under memory pressure.

The larger the memory the more problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
