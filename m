Date: Wed, 12 Sep 2007 17:53:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 17 of 24] apply the anti deadlock features only to global
 oom
In-Reply-To: <20070912060202.dc0cc7ab.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709121752500.4489@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random> <efd1da1efb392cc4e015.1187786944@v2.random>
 <20070912060202.dc0cc7ab.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Andrew Morton wrote:

> ok, I'm starting to get lost here.  Let's apply it unreviewed and if it
> breaks, that'll teach the numa weenies about the value of code review ;)

Nack. We shuld really try to consolidate the locking consistently. The 
cpuset lock and the OOM_kill lock are duplicating things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
